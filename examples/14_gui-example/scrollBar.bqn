# This example depends on raygui

⟨⟨red, white, black, raywhite⟩⇐color, window, draw, rf⇐raylib, low⟩←r←•Import "../../rayed.bqn"
rg ← •Import "../../ffi/raygui.bqn"

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
DrawStyleEditControls ← {𝕊borderWidth‿arrowsSize‿sliderPadding‿sliderWidth‿arrowVisible‿scrollbarSide‿scrollbarWidth:
  # ScrollPanel style controls
  #----------------------------------------------------------
  rg.GuiGroupBox 550‿170‿220‿205⋈"SCROLLBAR STYLE"

  ·‿⟨tempBorderWidth⟩ ← rg.GuiSpinnerRef⟨670‿190‿90‿20, 20↑"BORDER_WIDTH", ⟨borderWidth⟩, 0, 6, 0⟩
  rg.GuiSetStyle ⟨guiControl.scrollbar⋄guiControlProperty.border_width⋄tempBorderWidth⟩
  
  ·‿⟨newArrowsSize⟩ ← rg.GuiSpinnerRef⟨670‿215‿90‿20, 21↑"ARROWS_SIZE", ⟨arrowsSize⟩, 4, 14, 0⟩
  rg.GuiSetStyle ⟨guiControl.scrollbar⋄guiScrollBarProperty.arrowsSize⋄newArrowsSize⟩

  ·‿⟨tempSliderPadding⟩ ← rg.GuiSpinnerRef⟨670‿240‿90‿20, 20↑"SLIDER_PADDING", ⟨sliderPadding⟩, 0, 14, 0⟩
  ·‿⟨newSliderPadding⟩ ← rg.GuiSpinnerRef⟨670‿320‿90‿20, 20↑"SLIDER_PADDING", ⟨tempSliderPadding⟩, 0, 14, 0⟩
  rg.GuiSetStyle ⟨guiControl.scrollbar⋄guisliderproperty.slider_padding⋄newSliderPadding⟩

  ·‿⟨newArrowsVisible⟩ ← rg.GuiCheckBoxRef⟨565‿280‿20‿20, "ARROWS_VISIBLE", ⟨arrowVisible⟩⟩
  rg.GuiSetStyle ⟨guiControl.scrollbar⋄guiscrollbarproperty.arrowsVisible⋄newArrowsVisible⟩
  
  ·‿⟨newSliderWidth⟩ ← rg.GuiSpinnerRef⟨670‿345‿90‿20, 21↑"SLIDER_WIDTH", ⟨sliderWidth⟩, 2, 100, 0⟩
  rg.GuiSetStyle ⟨guiControl.scrollbar⋄guiSliderProperty.slider_width⋄newSliderWidth⟩

  text ← "SCROLLBAR: "∾"RIGHT"‿"LEFT"⊑˜rg.scrollbar_left_side=scrollbarSide

  ·‿⟨newScrollbarSide⟩ ← rg.GuiToggleRef⟨560‿110‿200‿35, text, ⟨scrollbarSide⟩⟩
  rg.GuiSetStyle ⟨guiControl.listView⋄guiListViewProperty.scrollbarSide⋄newScrollbarSide⟩

  #----------------------------------------------------------
  # ScrollBar style controls
  #----------------------------------------------------------
  rg.GuiGroupBox 550‿20‿220‿135⋈"SCROLLPANEL STYLE"

  ·‿⟨newScrollbarWidth⟩ ← rg.GuiSpinnerRef⟨670‿30‿90‿20, 18↑"SCROLLBAR_WIDTH", ⟨scrollbarWidth⟩, 6, 30, 0⟩
  rg.GuiSetStyle ⟨guiControl.listView⋄guiListViewProperty.scrollbarWidth⋄newScrollbarWidth⟩

  ·‿⟨newBorderWidth⟩ ← rg.GuiSpinnerRef⟨670‿55‿90‿20, 20↑"BORDER_WIDTH", ⟨tempBorderWidth⟩, 0, 20, 0⟩
  rg.GuiSetStyle ⟨guiControl.default⋄guiControlProperty.borderWidth⋄newBorderWidth⟩

  newBorderWidth‿newArrowsSize‿newSliderPadding‿newSliderWidth‿newArrowsVisible‿newScrollbarSide‿newScrollbarWidth
}

# Main game loop
PerFrame ← {𝕊panelScroll‿panelView‿panelContentRec‿showContentArea‿drawState:
  rf.DrawText⟨{𝕊a‿b:a∾", "∾b}'-'⍟('¯'⊸=)¨∘•Repr¨ 2↑panelScroll, 4, 4, 20, red⟩

  panelScrollNew‿panelViewNew ← {𝕊panelScroll‿panelView:
    a‿b⊣·‿⟨a⟩‿⟨b⟩←rg.GuiScrollPanelRef⟨panelRec, ⟨⟩, panelContentRec, ⋈panelScroll, ⋈panelView⟩
  }⌾(2‿4⊸(↑¨)) panelScroll‿panelView

  {𝕤
    rg.GuiGridRef⟨(panelRec+○(2⊸↑)panelScrollNew)∾2↓panelContentRec, "", 16, 3, ⋈0‿0⟩
  } draw._withinRectangle +`2‿2⥊panelViewNew

  (⌈∘÷⟜10⌾(3⊸⊑)red) r.draw.Rectangle⍟showContentArea +`(panelRec+○(2⊸↑)panelScrollNew)≍¯2↑panelContentRec

  newDrawState ← DrawStyleEditControls drawState

  ·‿⟨showContentAreaNew⟩←rg.GuiCheckBoxRef⟨565‿80‿20‿20, "SHOW CONTENT AREA", ⟨showContentArea⟩⟩

  panelContentRecNew ← {𝕊width‿height:
    ⊑¨1⊑¨rg.GuiSliderBarRef¨⟨
      ⟨590‿385‿145‿15, "WIDTH" , •Repr width , ⋈width , 0, 600⟩
      ⟨590‿410‿145‿15, "HEIGHT", •Repr height, ⋈height, 0, 400⟩
    ⟩
  }⌾(2⊸↓) panelContentRec

  panelScrollNew‿panelViewNew‿panelContentRecNew‿showContentAreaNew‿newDrawState
} draw._withCanvas_ r.color.black

Start ← {𝕤
  panelContentRec ← 0‿0‿340‿340
  panelView       ← 4⥊0
  panelScroll     ← 99‿¯20‿0‿0

  showContentArea ← 1

  drawState ← { # Draw and process scroll bar style edition controls
    borderWidth    ⇐ 1
    arrowsSize     ⇐ 0
    sliderPadding  ⇐ 0
    sliderWidth    ⇐ 3
    arrowVisible   ⇐ 0
    scrollbarSide  ⇐ 0
    scrollbarWidth ⇐ 6
  }
  PerFrame •_While_(¬window.ShouldClose) panelScroll‿panelView‿panelContentRec‿showContentArea‿drawState
}

Start window._openAs "raygui - GuiScrollPanel()"
