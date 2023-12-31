function removePathFromFullPath(fullPath, pathToRemove)
    -- Replace backslashes with forward slashes for platform independence
    fullPath = fullPath:gsub("\\", "/")
    pathToRemove = pathToRemove:gsub("\\", "/")

    -- Normalize paths by removing trailing slashes
    fullPath = fullPath:gsub("/$", "")
    pathToRemove = pathToRemove:gsub("/$", "")

    local fullPathLen = #fullPath
    local pathToRemoveLen = #pathToRemove

    local i = 1
    while i <= fullPathLen and i <= pathToRemoveLen do
        if fullPath:sub(i, i) == pathToRemove:sub(i, i) then
            i = i + 1
        else
            break
        end
    end

    if i > pathToRemoveLen then
        -- Remove pathToRemove and any leading slash
        return fullPath:sub(i + 1)
    else
        return fullPath
    end
end

-- Function to open the buffer list window in order of usage with the first and second buffers swapped
function OpenBufferListWindow()
	-- Use vim.fn.execute to capture the output of ":ls t"
	local buffer_list = vim.fn.execute("ls t")
  
	-- Split the buffer list into lines
	local buf_names = vim.split(buffer_list, "\n")
  
	-- Remove the first line (header)
	table.remove(buf_names, 1)
  
	-- Check if there are at least two buffers
	if #buf_names >= 2 then
		-- Swap the first and second buffers
		local temp = buf_names[1]
		buf_names[1] = buf_names[2]
		buf_names[2] = temp
	end

	local cwdpath = vim.fn.getcwd():gsub("%~", vim.fn.expand('$HOME')):gsub("\\", "/")

	local path1 = cwdpath
	local path2 = ""

  
	-- Extract the buffer names within double quotes
	local buffer_names = {}
	for _, line in ipairs(buf_names) do
		local name = line:match('"([^"]+)"')
		if name then
			local myname = name:gsub("%~", vim.fn.expand('$HOME')):gsub("\\", "/")
			
			path2 = myname

			-- print(path1, path2)

			local remainingPath = removePathFromFullPath(path2, path1)
			-- print(remainingPath)


			table.insert(buffer_names, remainingPath)
		end
	end
  
	vim.ui.select(buffer_names, {
	  prompt = "Navigate to a Buffer",
	}, function(selected)
	  if selected ~= "" and selected ~= nil then
		vim.cmd('buffer ' .. selected)
	  end
	end)
  end
  
  -- Set the keybinding to toggle the buffer list window
  vim.api.nvim_set_keymap('n', '<leader>bb', '<Cmd>lua OpenBufferListWindow()<CR>', { noremap = true, silent = true })
