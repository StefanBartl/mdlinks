---@meta
---@module 'mdlinks.core.types.parser'

---@class MdLink
---@field raw string
---@field text string
---@field target string
---@field kind  "url"|"file"|"image"|"heading"

---@class MdLinkHit : MdLink
---@field s integer  -- 1-based start col (inclusive)
---@field e integer  -- 1-based end col (inclusive)
