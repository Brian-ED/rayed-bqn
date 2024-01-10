# This example depends on raygui

⟨⟨red, white, black, raywhite⟩⇐color, window, draw, rf⇐rayffi, low⟩←r←•Import "../../raylib.bqn"
rg ← •Import "../../raygui.bqn"
⟨
  guiControl
  guiControlProperty
  guiScrollBarProperty
  guiSliderProperty
  guiListViewProperty
⟩← rg

x‿y‿width‿height ← ↕4 # indecies of rectangle
panelRec ← 20‿40‿200‿150

# Draw and process scroll bar style edition controls
DrawStyleEditControls ← {𝕊:
  # ScrollPanel style controls
  #----------------------------------------------------------
  rg.GuiGroupBox 550‿170‿220‿205⋈"SCROLLBAR STYLE"

  rg.GuiLabel 555‿195‿110‿10⋈"BORDER_WIDTH"
  rg.GuiLabel 555‿220‿110‿10⋈"ARROWS_SIZE"
  rg.GuiLabel 555‿245‿110‿10⋈"SLIDER_PADDING"
  rg.GuiLabel 555‿325‿110‿10⋈"SLIDER_PADDING"
  rg.GuiLabel 555‿350‿110‿10⋈"SLIDER_WIDTH"
  _GUI ← {
    ·‿⟨newStyle⟩ ← 𝔽 rg.GuiGetStyle 𝕩
    rg.GuiSetStyle 𝕩∾<newStyle
  }
  {
    rg.GuiSpinnerRef⟨670‿190‿90‿20, "", ⟨𝕩⟩, 0, 6, 0⟩
  } _GUI guiControl.scrollbar‿guiControlProperty.border_width
  {
    rg.GuiSpinnerRef⟨670‿215‿90‿20, "", ⟨𝕩⟩, 4, 14, 0⟩
  } _GUI guiControl.scrollbar‿guiScrollBarProperty.arrowsSize
  {
    rg.GuiSpinnerRef⟨670‿240‿90‿20, "", ⟨𝕩⟩, 0, 14, 0⟩
  } _GUI guiControl.scrollbar‿guiSliderProperty.slider_padding
  {
    rg.GuiCheckBoxRef⟨565‿280‿20‿20, "ARROWS_VISIBLE", ⟨𝕩⟩⟩
  } _GUI guiControl.scrollbar‿guiscrollbarproperty.arrows_visible
  {
    rg.GuiSpinnerRef⟨670‿320‿90‿20, "", ⟨𝕩⟩, 0, 14, 0⟩
  } _GUI guiControl.scrollbar‿guisliderproperty.slider_padding
  {
    rg.GuiSpinnerRef⟨670‿345‿90‿20, "", ⟨𝕩⟩, 2, 100, 0⟩
  } _GUI guiControl.scrollbar‿guiSliderProperty.slider_width
  text ← "SCROLLBAR: RIGHT"‿"SCROLLBAR: LEFT"⊑˜rg.scrollbar_left_side=rg.GuiGetStyle guiControl.listView‿guiListViewProperty.scrollbarSide
  {
    rg.GuiToggleRef⟨560‿110‿200‿35, text, ⟨𝕩⟩⟩
  } _GUI guiControl.listView‿guiListViewProperty.scrollbarSide
  #----------------------------------------------------------

  # ScrollBar style controls
  #----------------------------------------------------------
  rg.GuiGroupBox 550‿20‿220‿135⋈"SCROLLPANEL STYLE"

  rg.GuiLabel 555‿35‿110‿10⋈"SCROLLBAR_WIDTH"
  {
    rg.GuiSpinnerRef⟨670‿30‿90 ‿20, ⟨⟩, ⟨𝕩⟩, 6, 30, 0⟩
  } _GUI guiControl.listView‿guiListViewProperty.scrollbarWidth
  rg.GuiLabel 555‿60‿110‿10⋈"BORDER_WIDTH"
  {
    rg.GuiSpinnerRef⟨670‿55‿90‿20, ⟨⟩, ⟨𝕩⟩, 0, 20, 0⟩
  } _GUI guiControl.default‿guiControlProperty.border_width
}

# Main game loop
PerFrame ← {𝕊panelScroll‿panelView‿panelContentRec‿showContentArea:
  rf.DrawText⟨{𝕊a‿b:a∾", "∾b}'-'⍟('¯'⊸=)¨∘•Repr¨ 2↑panelScroll, 4, 4, 20, red⟩

  panelScrollNew‿panelViewNew ← {𝕊panelScroll‿panelView:
    a‿b⊣·‿⟨a⟩‿⟨b⟩←rg.GuiScrollPanelRef⟨panelRec, ⟨⟩, panelContentRec, ⋈panelScroll, ⋈panelView⟩
  }⌾(2‿4⊸(↑¨)) panelScroll‿panelView

  {𝕤
    rg.GuiGridRef⟨(panelRec+○(2⊸↑)panelScrollNew)∾2↓panelContentRec, "", 16, 3, ⋈0‿0⟩
  } draw._withinRectangle +`2‿2⥊panelViewNew

  (⌈∘÷⟜10⌾(3⊸⊑)red) r.draw.Rectangle⍟showContentArea +`(panelRec+○(2⊸↑)panelScrollNew)≍¯2↑panelContentRec

  DrawStyleEditControls⟨⟩

  ·‿⟨showContentAreaNew⟩←rg.GuiCheckBoxRef⟨565‿80‿20‿20, "SHOW CONTENT AREA", ⟨showContentArea⟩⟩

  panelContentRecNew ← {width‿height:
    ⊑¨1⊑¨rg.GuiSliderBarRef¨⟨
      ⟨590‿385‿145‿15, "WIDTH" , •Repr width , ⋈width , 0, 600⟩
      ⟨590‿410‿145‿15, "HEIGHT", •Repr height, ⋈height, 0, 400⟩
    ⟩
  }⌾(2⊸↓) panelContentRec

  panelScrollNew‿panelViewNew‿panelContentRecNew‿showContentAreaNew
} draw._withCanvas_ raywhite

Start ← {𝕤
  panelContentRec ← 0 ‿ 0‿340‿340
  panelView       ← 4⥊0
  panelScroll     ← 99‿¯20‿0‿0

  showContentArea ← 1

  DrawStyleEditControls⟨⟩  # Draw and process scroll bar style edition controls
  PerFrame •_While_(¬window.ShouldClose) panelScroll‿panelView‿panelContentRec‿showContentArea
}

Start window._openAs "raygui - GuiScrollPanel()"
