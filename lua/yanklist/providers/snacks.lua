local M = {}
local utils = require('yanklist.utils')
local get_yanklist = vim.fn['yanklist#read']

local paste_content = function(item, is_visual, put_after)
  if not item then
    return
  end

  local regtype = item.regtype
  local lines = item.data

  if is_visual then
    vim.schedule(function()
      vim.cmd('normal! gv"_d')
      vim.api.nvim_put(lines, regtype, false, true)
    end)
    return
  end

  vim.schedule(function()
    vim.api.nvim_put(lines, regtype, put_after, true)
  end)
end

function M.yanklist(is_visual, opts)
  is_visual = utils.get_default(is_visual, false)
  opts = utils.get_default(opts, {})

  Snacks.picker.pick({
    finder = function(options, filter)
      local reg_state = get_yanklist()

      ---@type snacks.picker.finder.Item[]
      local items = {}

      for _, item in ipairs(reg_state) do
        local chartype = item[2] == 'v' and 'char' or 'line'

        local text = table.concat(item[1], '')
        local preview = table.concat(item[1], '\n')

        table.insert(items, {
          chartype = chartype,
          regtype = item[2],
          data = item[1],
          text = vim.trim(text),
          preview = { text = preview, ft = 'text' },
        })
      end
      return items
    end,
    preview = 'preview',
    format = function(item, _)
      local ret = {} ---@type snacks.picker.Highlight[]
      ret[#ret + 1] = { item.chartype, 'SnacksPickerCol' }
      ret[#ret + 1] = { ' ' }
      ret[#ret + 1] = { Snacks.picker.util.align(tostring(item.idx), 2, { align = 'right' }), 'SnacksPickerBufNr' }
      ret[#ret + 1] = { ' ' }
      ret[#ret + 1] = { item.text }
      return ret
    end,
    actions = {
      yank = function(picker, item)
        picker:close()
        if item then
          vim.fn.setreg('+', item.data or item.text, item.regtype)
        end
      end,
      paste_before = function(picker, item)
        picker:close()
        if item then
          paste_content(item, is_visual, false)
        end
      end,
    },
    confirm = function(picker, item)
      picker:close()
      if item then
        paste_content(item, is_visual, true)
      end
    end,
    win = {
      input = {
        keys = {
          ['<c-y>'] = { 'yank', mode = { 'n', 'i' } },
          ['<c-t>'] = { 'paste_before', mode = { 'n', 'i' } },
        },
      },
    },
  })
end

return M
