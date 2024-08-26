return {
  "windwp/nvim-autopairs",
  config = function(plugin, opts)
    -- run default AstroNvim config
    require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts)
    -- require Rule function
    local Rule = require "nvim-autopairs.rule"
    local npairs = require "nvim-autopairs"

    npairs.add_rules {
      Rule("~", "~", "org"):with_pair(function(opts)
        -- Only add the pair if the next character is a space or empty
        local pair = opts.line:sub(opts.col, opts.col + 1)
        return pair:match "%s" or pair == ""
      end),
    }
  end,
}
