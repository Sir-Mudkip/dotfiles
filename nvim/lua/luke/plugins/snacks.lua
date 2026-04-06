return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    opts = {
      dashboard = {
        width = 60,
        row = nil,
        col = nil,
        pane_gap = 4,
        autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
        preset = {
          pick = nil,
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
          header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        },
        formats = {
          icon = function(item)
            if item.file and item.icon == "file" or item.icon == "directory" then
              return Snacks.dashboard.icon(item.file, item.icon)
            end
            return { item.icon, width = 2, hl = "icon" }
          end,
          footer = { "%s", align = "center" },
          header = { "%s", align = "center" },
          file = function(item, ctx)
            local fname = vim.fn.fnamemodify(item.file, ":~")
            fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
            if #fname > ctx.width then
              local dir = vim.fn.fnamemodify(fname, ":h")
              local file = vim.fn.fnamemodify(fname, ":t")
              if dir and file then
                file = file:sub(-(ctx.width - #dir - 2))
                fname = dir .. "/…" .. file
              end
            end
            local dir, file = fname:match("^(.*)/(.+)$")
            return dir and { { dir .. "/", hl = "dir" }, { file, hl = "file" } } or { { fname, hl = "file" } }
          end,
        },
        sections = {
        { section = "header" },
        { pane = 2, section = "terminal", cmd = "pokemon-colorscripts -s --random; sleep .1", indent = 1, height = 25, padding = 2, },
    { section = "keys", gap = 1, padding = 4 },
    { pane = 3, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
    { pane = 3, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
    { section = "startup" },
  },
      },
      styles = {
        snacks_image = {
          relative = "editor",
          col = -1,
        },
      },
      image = {
          enabled = true,
          force = true,
          doc = {
              enabled = true,
              inline = false,
              -- render the image in a floating window
              -- only used if `opts.inline` is disabled
              float = true,
              -- Sets the size of the image
              max_width = 100,
              max_height = 60,
              win_config = function(width, height)
                return {
                relative = "editor",
                style = "minimal",
                border = "rounded",
    -- Exact bottom right corner
                row = vim.o.lines - height - 1,    -- 1 line from bottom
                col = vim.o.columns - width - 1,   -- 1 column from right
                width = width,
                height = height,
            }
        end
              -- Apparently, all the images that you preview in neovim are converted
          -- to .png and they're cached, original image remains the same, but
          -- the preview you see is a png converted version of that image
          --
          -- Where are the cached images stored?
          -- This path is found in the docs
          -- :lua print(vim.fn.stdpath("cache") .. "/snacks/image")
          -- For me returns `~/.cache/neobean/snacks/image`
          -- Go 1 dir above and check `sudo du -sh ./* | sort -hr | head -n 5`
        },
        img_dirs = {
          vim.fn.expand("~") .. "/Documents/Pentesting Notes/Pasted Images",
          vim.fn.expand("~") .. "/Documents/Pentesting Notes",
        },
        -- SIMPLIFIED PATH RESOLUTION
        resolve = function(file, src)
          local absolute_paths = {
            vim.fn.expand("~") .. "/Documents/Pentesting Notes/Pasted Images/" .. vim.fn.fnamemodify(src, ":t"),
            vim.fn.expand("~") .. "/Documents/Pentesting Notes/" .. vim.fn.fnamemodify(src, ":t"),
            vim.fn.expand("~") .. "/Pictures/Screenshots/" .. vim.fn.fnamemodify(src, ":t"),
      }
          for _, path in ipairs(absolute_paths) do
            if vim.fn.filereadable(path) == 1 then
              return path
            end
          end 
          return nil
        end,   
      },
    },
},
}
