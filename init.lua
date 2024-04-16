local mainScreen = hs.screen.mainScreen()
local screenFrame = mainScreen:frame()

--[[
Mark & Return

Allows users to "mark" the current set of windows by name and return to them later.lc
]]--
 markedWindows = {}
 listOfOpenWindowsObject = setmetatable({}, { __index = function(t, k) return {} end })


--[[
When the user presses command + control + M, 
open a dialog to allow the user to enter the handle
for the current window stack, sizing, and dimensionality.
]]--
hs.hotkey.bind({"cmd", "ctrl"}, "M", function()
  local option, dialog = hs.dialog.textPrompt("Mark & Return", "Enter a mark", "", "OK", "Cancel", false)
  if option ~= "OK" then
    return
  end

  -- Remove entries with matching "mark" property
  for i = #listOfOpenWindowsObject, 1, -1 do
    if listOfOpenWindowsObject[i].mark == dialog then
      table.remove(listOfOpenWindowsObject, i)
    end
  end

  --[[
  start Mark & Return.
  v1: Replace marked windows with the newly-marked windows
  ]]--
  local listOfOpenWindows = hs.window.orderedWindows()
  for i, window in ipairs(listOfOpenWindows) do
    -- Only load windows that are actually visible
    table.insert(listOfOpenWindowsObject, {
      window = window, 
      mark = dialog, 
      size = window:size(), 
      position = window:frame()
    })
  end

  hs.alert.show("Marked " .. #listOfOpenWindowsObject .. " windows")
end)

function getMarks()
  local marks = {}
  for i = 1, #listOfOpenWindowsObject do
    local mark = listOfOpenWindowsObject[i].mark
    if mark and not marks[mark] then
      marks[mark] = true
    end
  end
  return marks
end

function getListOfMarks(marks)
  local marksList = "Marked window configs:"
  for mark, _ in pairs(marks) do
    marksList = marksList .. "\n" .. mark .. "\n"
  end
  return marksList
end


--[[
When the user presses command + control + R, 
Allow the user to recall the exact positioning of windows from
when they had originally "marked" them with a specific handle.
]]--

hs.hotkey.bind({"cmd", "ctrl"}, "R", function()
  -- Get all unique marks
  local marks = getMarks()

  local marksList = getListOfMarks(marks)

  local option, dialog = hs.dialog.textPrompt("Recall windows", marksList, "", "OK", "Cancel", false)
  -- local option, dialog = hs.dialog.textPrompt("Recall windows", "Set marks: ", "", "OK", "Cancel", false)
  if option ~= "OK" then
    return
  end
  for i = #listOfOpenWindowsObject, 1, -1 do -- Back to front so we front elements end up on top after focusing each
    local windowObject = listOfOpenWindowsObject[i]
    if windowObject.mark == dialog and windowObject.window then
      --hs.alert.show("Returning window!")
      windowObject.window:focus(true)
      windowObject.window:setSize(windowObject.size)
      windowObject.window:setFrame(windowObject.position)
    end
  end
  hs.alert.show("Windows restored!")
end)

--[[
When the user presses command + control + D,
Allow users to prune old, unused handles.
]]--

hs.hotkey.bind({"cmd", "ctrl"}, "D", function()
  local marks = getMarks()
  local marksList = getListOfMarks(marks)

  local option, dialog = hs.dialog.textPrompt("Remove mark", marksList, "", "OK", "Cancel", false)

  if option ~= "OK" then
    return
  end

  for i = #listOfOpenWindowsObject, 1, -1 do
    if listOfOpenWindowsObject[i].mark == dialog then
      table.remove(listOfOpenWindowsObject, i)
    end
  end
end)