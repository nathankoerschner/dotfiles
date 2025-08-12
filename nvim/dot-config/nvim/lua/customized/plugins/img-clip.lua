return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    -- add options here
    --
    default = {
      -- make dir_path relative to current file rather than the cwd
      -- To see your current working directory run `:pwd`
      -- So if this is set to false, the image will be created in that cwd
      -- In my case, I want images to be where the file is, so I set it to true
      relative_to_current_file = true, ---@type boolean

      -- I want to save the images in a directory named after the current file,
      -- but I want the name of the dir to end with `-img`
      dir_path = './',
      show_dir_path_in_prompt = true,
      file_name = ".%Y-%m-%d-at-%H-%M-%S",
    },
    -- or leave it empty to use the default settings
  },
  keys = {
    -- suggested keymap
    { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
  },
}
