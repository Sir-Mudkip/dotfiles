-- Dashboard configuration and startup screen customization
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    opts = {
      dashboard = {
        width = 80,
        preset = {
          header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
          keys = {
            { icon = "", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = "", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = "󰦨", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = "", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = "", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = "󰦛", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = "󰩈", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          { section = "header", padding = 2 },
          { section = "keys", padding = 2 },
          { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 2 },
          { section = "startup" },
        },
      },
      words = { enabled = true },
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
          float = true,
          max_width = 100,
          max_height = 60,
          win_config = function(width, height)
            return {
              relative = "editor",
              style = "minimal",
              border = "rounded",
              row = vim.o.lines - height - 1,
              col = vim.o.columns - width - 1,
              width = width,
              height = height,
            }
          end,
        },
        img_dirs = {
          vim.fn.expand("~") .. "/Documents/Pentesting Notes/Pasted Images",
          vim.fn.expand("~") .. "/Documents/Pentesting Notes",
        },
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
