vim.filetype.add({
  extension = { rc = "sh" },
  filename = { Brewfile = "ruby", [".Brewfile"] = "ruby" },
  pattern = { [".*%.Brewfile"] = "ruby", [".*%.rc"] = "sh" },
})
