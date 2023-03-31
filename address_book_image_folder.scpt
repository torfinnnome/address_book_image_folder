-- Set selected Address Book contact pictures from a folder with jpg files,
-- like from Google Takeout.
-- Released under GPL.
-- Original version: Jonathan Henrique de Souza, https://github.com/jonathanhds/address_book_gravatar
-- Slightly modified by Torfinn Nome, https://github.com/torfinnnome/address_book_image_folder

-- Grab the selected records and see how many there are.
tell application "Contacts"
	set selected_contacts to selection
	set count_selected to number of items in selected_contacts
	
	-- Bail out if there are no records selected. Otherwise ask about how to deal 
	-- with contacts having existing pictures.
	if count_selected < 1 then
		tell me to display dialog "You must first select some Address Book contacts." buttons {"Cancel"} default button 1 cancel button 1
	else
		if count_selected = 1 then
			set plural to ""
		else
			set plural to "s"
		end if
		tell me to set user_result to display dialog "We're about to try updating " & count_selected & " selected Address Book contact picture" & plural & " from a folder. Would you like to overwrite existing pictures or skip those contacts?" buttons {"Cancel", "Overwrite Existing", "Skip Existing"} cancel button 1 default button 1 with icon caution
		set overwrite to (button returned of user_result contains "Overwrite")
	end if
	
	set image_folder to choose folder with prompt "Please select folder with contacts images:"
	
	-- Step through each contact and try to find an image file.
	repeat with one_contact in selected_contacts
		if not ((image of one_contact exists) and not overwrite) then
			-- Try to find an image.
			set user_name to name of one_contact
			set image_file to (my get_image(image_folder, user_name))
			
			-- If we have an image file add it to the contact.
			if image_file is not "" then
				set image of one_contact to my get_pict_data(image_file)
			end if
			save
		end if
	end repeat
	tell me to display dialog "Done. You may need to select a different record to force Address Book to refresh the screen before changes show." buttons {"Okay"} default button 1
end tell

-- Look up a jpg file from a folder with jpg files. File name should be the same as the contact's name + ".jpg".
on get_image(image_folder, user_name)
	set image_file to (POSIX path of image_folder) & user_name & ".jpg"
	tell application "System Events"
		if exists file image_file then
			return image_file
		else
			return ""
		end if
	end tell
end get_image

-- Read the picture data into a variable in TIFF format.
on get_pict_data(image_file)
	tell application "System Events"
		set file_ref to open for access image_file
		set pict_data to read file_ref as "TIFF"
		close access file_ref
		return pict_data
	end tell
end get_pict_data
