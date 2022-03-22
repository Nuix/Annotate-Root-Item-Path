# This essentially "bootstraps" the library from a Ruby script
# The following code can easily be copied to the top of your
# new script to get you started.
#
# This code loads the JAR from the same directory the script file
# is located, then loads up a few commonly used classes from the
# JAR and then performs a few initialization tasks:
# - Make sure the Java look and feel is Windows in case were running via nuix_console.exe
#   this step makes sure the look is consistent regardless of where the script is ran
# - Pass an instance of the Utilities object to the library for its use
# - Pass the current Nuix version string to the library

script_directory = File.dirname(__FILE__)
require File.join(script_directory,"Nx.jar")
java_import "com.nuix.nx.NuixConnection"
java_import "com.nuix.nx.LookAndFeelHelper"
java_import "com.nuix.nx.dialogs.ChoiceDialog"
java_import "com.nuix.nx.dialogs.TabbedCustomDialog"
java_import "com.nuix.nx.dialogs.CommonDialogs"
java_import "com.nuix.nx.dialogs.ProgressDialog"
java_import "com.nuix.nx.dialogs.ProcessingStatusDialog"
java_import "com.nuix.nx.digest.DigestHelper"
java_import "com.nuix.nx.controls.models.Choice"

LookAndFeelHelper.setWindowsIfMetal
NuixConnection.setUtilities($utilities)
NuixConnection.setCurrentNuixVersion(NUIX_VERSION)

dialog = TabbedCustomDialog.new("Annotate Root Item Path")

main_tab = dialog.addTab("main_tab","Main")
if !$current_selected_items.nil? && $current_selected_items.size > 0
	main_tab.appendHeader("Using #{$current_selected_items.size} selected items")
else
	main_tab.appendHeader("Using all #{$current_case.count("")} items in case")
end
main_tab.appendSpinner("root_item_path_depth","Root Item Path Depth",4,1,100)
main_tab.appendCheckBox("include_evidence_container","Include Evidence Container",true)
main_tab.appendTextField("custom_field_name","Custom Field Name","Root Item Path")
main_tab.appendCheckBox("inverted_result","Invert Result",false)

dialog.validateBeforeClosing do |values|
	if values["custom_field_name"].strip.empty?
		CommonDialogs.showWarning("Please provide a custom metadata field name")
		next false
	end

	# Get user confirmation about closing all workbench tabs
	if CommonDialogs.getConfirmation("The script needs to close all workbench tabs, proceed?") == false
		next false
	end

	next true
end

dialog.display
if dialog.getDialogResult == true
	values = dialog.toMap

	root_item_path_depth = values["root_item_path_depth"]
	include_evidence_container = values["include_evidence_container"]
	custom_field_name = values["custom_field_name"]
	inverted_result = values["inverted_result"]

	ProgressDialog.forBlock do |pd|
		$window.closeAllTabs
		pd.setTitle("Annotate Root Item Path")

		pd.logMessage("Root Item Path Depth: #{root_item_path_depth}")
		pd.logMessage("Include Evidence Container: #{include_evidence_container}")
		pd.logMessage("Custom Field Name: #{custom_field_name}")

		start_time = Time.now
		last_progress = Time.now
		annotater = $utilities.getBulkAnnotater

		items = nil
		if !$current_selected_items.nil? && $current_selected_items.size > 0
			items = $current_selected_items
		else
			items = $current_case.searchUnsorted("")
		end

		pd.setMainStatus("Processing Items...")
		pd.setMainProgress(0,items.size)

		items.each_with_index do |item,item_index|
			break if pd.abortWasRequested

			path_names = item.getLocalisedPathNames.to_a

			value_to_record = ""

			if inverted_result
				if path_names.size > root_item_path_depth
					value_to_record = path_names.drop(root_item_path_depth).join("/")
				end
			else
				if !include_evidence_container
					path_names.shift
				end

				root_path_names = path_names.take(root_item_path_depth)
				value_to_record = root_path_names.join("/")
			end

			annotater.putCustomMetadata(custom_field_name,value_to_record,Array(item),"text","user",nil,nil)

			if (Time.now - last_progress) > 1 || (item_index+1) == items.size
				pd.setMainStatus("Processing Items #{item_index+1}/#{items.size}")
				pd.setMainProgress(item_index+1)
				last_progress = Time.now
			end
		end
		finish_time = Time.now

		if pd.abortWasRequested
			pd.setMainStatusAndLogIt("User Aborted")
		else
			pd.setCompleted
		end
		pd.logMessage("#{finish_time - start_time} seconds")
		query = "custom-metadata:\"#{custom_field_name}\":*"
		$window.openTab("workbench",{:search => query})
	end
end