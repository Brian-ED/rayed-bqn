⟨ParseXML⇐Parse⟩ ← •Import "../../imports/bqn-libs/xml.bqn"
⟨ToNums⟩ ← •Import "../../imports/bqn-libs/strings.bqn"
⟨Inverse⋄MP⟩ ← •Import "../../imports/bqn-libs/matrix.bqn"
⟨color⟩ ← •Import "../constants.bqn"

_MatFuncToListFunc ← {⥊2↑˘𝔽○(0‿0‿1∾˘˜3‿2⊸⥊)}

NSVG__xformmultiply ← MP _MatFuncToListFunc
NSVG__xforminverse ← Inverse _MatFuncToListFunc

# Parses SVG file from a null terminated string, returns SVG image as paths.
_ParseSVG_ ← {StartOperation _𝕣_ EndOperation svgChars:
  {
    ⟨⟩≡≢𝕩? @
    ; name‿args‿inside:
        name StartOperation args
        𝕊¨inside
        name EndOperation args
    ; name‿args:
      name StartOperation args
      name EndOperation args
    ;
      !⟨"missed this with shape "∾•Repr ≢𝕩⋄𝕩⟩
  }¨ ParseXML svgChars
}

NSVG__getAverageScale ← {(+´÷≠)+˝⌾(×˜)2‿2⥊𝕩}

NSVG__xformSetSkewX ← {⥊[1‿0 ⋄ ⟨•math.Tan 𝕩⋄1⟩ ⋄ 0‿0]}
NSVG__xformSetSkewY ← {⥊[⟨1⋄•math.Tan 𝕩⟩ ⋄ 0‿1 ⋄ 0‿0]}
nsvg__xformIdentity ← ⥊3↑=⌜˜↕2
nsvg_KAPPA90 ← 0.5522847493 # Length proportional to radius of a cubic bezier handle for 90deg arcs.

NSVG__parseTransformArgs ← {𝕊str‿maxNa:
  maxNa↑⍟(≤⟜≠) ToNums str
}

NSVG__xformSetTranslation ← (⥊=⌜˜↕2)⊸∾

# returns NSVGparser
CreateState ⇐ {𝕊:
  npts ⇐ 0
  pts ⇐ ⟨⟩
  cpts ⇐ 0

  viewwidth ⇐ viewMinx ⇐ @

  NSVG__resetPath ⇐ {𝕊:
    npts↩0
  }
  image ⇐ 0
  defsFlag ⇐ 0
  SetDefsFlag ⇐ {defsFlag↩𝕩}

  dpi⇐0
  SetDPI ⇐ {dpi↩𝕩}

  pathFlag ⇐ 0
  SetPathFlag ⇐ {pathFlag↩𝕩}

  viewRec ⇐ 0‿0‿0‿0
  SetViewRec ⇐ {!4=≠𝕩⋄!∧´1=•Type¨𝕩⋄viewRec↩𝕩}

  shapesTail ⇐ @
  SetShapesTail ⇐ {shapesTail↩𝕩}

  NSVG__moveTo ⇐ {
   𝕊x‿y:
    npts > 0?
      pts 𝕩⌾((npts-1)⊸⊑)↩
  ;𝕊x‿y:
    NSVG__addPoint 𝕩
  }

  NSVG__addPoint ⇐ {𝕊x‿y:
    (npts+1) > cpts?
      cpts ↩ (×cpts) ⊑ 8⋈cpts
      pts ↩ cpts↑pts
  ;𝕊x‿y:
    pts 𝕩⌾(npts⊸⊑)↩
    npts+↩1
  }

#  paths ⇐ p.plist
#  p.SetPlist⟨⟩

  # Init style
  attr ⇐ ⟨
    {
      xform ⇐ 2↑˘=⌜˜3‿3
      id ⇐ 0
      fillColor ⇐ 0‿0‿0
      strokeColor ⇐ 0‿0‿0
      opacity ⇐ 1
      fillOpacity ⇐ 1
      strokeOpacity ⇐ 1
      stopOpacity ⇐ 1
      strokeWidth ⇐ 1
      strokeLineJoin ⇐ nsvglineJoin.nsvg_join_miter
      strokeLineCap ⇐ nsvglineCap.nsvg_cap_butt
      miterLimit ⇐ 4
      fillRule ⇐ nsvgfillRule.nsvg_fillrule_nonzero
      hasFill ⇐ 1
      visible ⇐ 1
    }
  ⟩
  NSVG__pushAttr ⇐ {𝕊:
    attr 1⊸↑⊸∾↩
  }
  NSVG__getAttr ⇐ {𝕊:
    ⊑attr
  }

  NSVG__popAttr ⇐ {𝕊:
    attr 1⊸↓⍟(1<≠)↩
  }
}
nsvGpaintType ← {
  nsvg_paint_none ⇐ 0
  nsvg_paint_color ⇐ 1
  nsvg_paint_linear_gradient ⇐ 2
  nsvg_paint_radial_gradient ⇐ 3
}

nsvgspreadType ← {
  nsvg_spread_pad ⇐ 0
  nsvg_spread_reflect ⇐ 1
  nsvg_spread_repeat ⇐ 2
}

nsvglineJoin ← {
  nsvg_join_miter ⇐ 0
  nsvg_join_round ⇐ 1
  nsvg_join_bevel ⇐ 2
}

nsvglineCap ← {
  nsvg_cap_butt ⇐ 0
  nsvg_cap_round ⇐ 1
  nsvg_cap_square ⇐ 2
}

nsvgfillRule ← {
  nsvg_fillrule_nonzero ⇐ 0
  nsvg_fillrule_evenodd ⇐ 1
}
nsvgflags ← {
  nsvg_flags_visible ⇐ 1
}
nsvg_align_min ⇐ 0
nsvg_align_mid ⇐ 1
nsvg_align_max ⇐ 2
nsvg_align_none ⇐ 0
nsvg_align_meet ⇐ 1
nsvg_align_slice ⇐ 2

nsvggradientunits ← {
  nsvg_user_space ⇐ 0
  nsvg_object_space ⇐ 1
}

NSVG__xformPoint ← {𝕊x‿y‿t:
  +˝x‿y‿1×3‿2⥊t
}

# returns NSVGgradientData*
NSVG__findGradientData ← {𝕊p‿id:
  ⊑@∾˜id⊸≡⟜{𝕩.id}¨⊸/p.gradients
}

# returns *NSVGgradient ‿ paintType
# input: NSVG_parser‿str‿*f‿str
NSVG__createGradient ← {𝕩‿𝕩.paintType}∘{𝕊p‿id‿localBounds:
  attr ← p.NSVG__getAttr@
  ref ← @  # NSVGgradientData*
  stops ← @  # NSVGgradientStop*
  nstops ⇐ 0

  data ← NSVG__findGradientData p‿id
  data≢@?
    # TODO: use ref to fill in all unset values too.
    refIter ← 0
    {𝕤
      (stops = @) ∧ 𝕩.stops ≠ @?
        stops ↩ 𝕩.stops
        nstops ↩ 𝕩.nstops
    ;
      nextRef ← NSVG__findGradientData p‿𝕩.ref
      nextRef≢𝕩? # prevent infite loops on malformed data
        refIter +↩ 1
        refIter ≤ 32? # prevent infite loops on malformed data
          𝕊⍟(@⊸≠) nextRef
    ;
      @
    }⍟(@⊸≠)data
    stops ≠ @?

      xform ⇐ 6⥊0
      fx‿fy ⇐ 0‿0
      # stops ⇐ ⟨
      #   {
      #     color ⇐ 0‿0‿0‿0
      #     offset ⇐ 0
      #   }
      # ⟩

      # The shape width and height.
      ox‿oy‿sw‿sh ← {data.units = nsvggradientunits.nsvg_object_space?
        -˜`2‿2⥊localBounds
      ;
        ⟨
          p.viewMinx
          p.viewMiny
          p.viewWidth
          p.viewHeigght
        ⟩
      }
      sl ← (√2)÷˜sw+⌾(×˜)sh

      {data.type = nsvGpaintType.nsvg_paint_linear_gradient?
        x1 ← p.NSVG__convertToPixels data.linear.x1‿ox‿sw
        y1 ← p.NSVG__convertToPixels data.linear.y1‿oy‿sh
        x2 ← p.NSVG__convertToPixels data.linear.x2‿ox‿sw
        y2 ← p.NSVG__convertToPixels data.linear.y2‿oy‿sh
        # Calculate transform aligned to the line
        dx ← x2 - x1
        dy ← y2 - y1
        xform ↩ [dy ⋄ -dx
                dx ⋄ dy
                x1 ⋄ y1]
      ;
        cx ← p.NSVG__convertToPixels ⟨data.radial.cx, ox, sw⟩
        cy ← p.NSVG__convertToPixels ⟨data.radial.cy, oy, sh⟩
        fx ↩ p.NSVG__convertToPixels ⟨data.radial.fx, ox, sw⟩
        fy ↩ p.NSVG__convertToPixels ⟨data.radial.fy, oy, sh⟩
        r  ← p.NSVG__convertToPixels ⟨data.radial.r, 0, sl⟩
        # Calculate transform aligned to the circle
        xform ↩ [r ⋄ 0
                0 ⋄ r
                cx⋄ cy]
        fx ÷↩ r
        fy ÷↩ r
      }

      xform NSVG__xformMultiply˜´↩ attr.xform‿data.xform

      spread ⇐ data.spread
      paintType ⇐ data.type
;
  @
}

NSVG__ptInBounds ← {𝕊pt‿bounds:
  ∧´(≤⟜pt∧pt⊸≤)´2(↑⋈↓)bounds
}

nsvg_epsilon ← 1e¯12

NSVG__evalBezier ← {𝕊t‿p:
  u ← ¬t
  +´0‿3‿3‿0×p××˝⍉[t⋄u]⊏˜4↑≤⌜˜↕3
}

NSVG__curveBounds ← {𝕊curve: # returns bounds
  roots ← 0‿0
  curve 4‿2⊸⥊↩ # ?

  # Start the bounding box by end points
  bounds ← (¯1⊏curve) (⌊∾⌈) ⊏curve

  # Bezier curve fits inside the convex hull of it's control points.
  # If control points are inside the bounds, we're done.
  {
    ∧´NSVG__ptInBounds¨(1‿2⊏curve)⋈¨<bounds?
      bounds
  ;
    # Add bezier curve inflection points in X and Y.
    {𝕊rowsOfV:
      a ← +´¯3‿9‿¯9‿3×𝕩
      b ← +´6‿¯12‿6×3↑𝕩
      c ← +´¯3‿3×2↑𝕩
      count ← 0
      {nsvg_epsilon > |a?
        {𝕤
          {roots 𝕩⌾((¯1+count+↩1)⊸⊑)↩}⍟(nsvg_epsilon⊸(<∧¬⊸>))b ÷˜ -c
        }⍟(nsvg_epsilon⊸<)|b
      ;
        {𝕤
          {𝕊:roots 𝕩⌾((¯1+count+↩1)⊸⊑)↩}⍟⊢¨nsvg_epsilon(<∧¬⊸>)a×2÷˜b-˜1‿¯1×√𝕩
        }⍟(nsvg_epsilon⊸<) b ×˜⊸- 4×c×a
      }
      {𝕤
        v ← NSVG__evalBezier⟨𝕩⊑roots⟩∾rowsOfV
        bounds v⊸⌊⌾((0+𝕩)⊸⊑)↩
        bounds v⊸⌈⌾((2+𝕩)⊸⊑)↩
      }¨↕count
    }˘⍉curve
    bounds
  }
}

NSVG__getLocalBounds ← {𝕊paths‿xform: # float*  NSVGshape* float*
  bounds ← 0‿0‿0‿0
  curve ← ⥊4‿2⥊0
  boundss ← {𝕊path:
    curves ← NSVG__xformPoint˘˘path.pts⊏˜⍉0‿1+⌜2×1+⌊‿3⥊↕1+path.npts
    start ← NSVG__xformPoint 2↑path.pts
    curveBoundss ← NSVG__curveBounds¨curves∾˜¨<¨start<⊸»¯1⊏˘curves
    (⌊○(2⊸↑) ∾ ⌈○(2⊸↓))´curveBoundss
  }¨paths
}

path←{npts⇐5}
•Show ↕∘⌈⌾(÷⟜3) •SHow path.npts-1


NSVG__addShape ← ⊢{parser𝕊shape:
  # Add to tail
  {
    parser.image.shapes = @?
      parser.image.AddShapes shape
  ;
    parser.shapesTail.SetNext shape
  }

  parser.SetShapesTail 𝕩

} {𝕩.plist=@?@; 𝕊p: # NSVGparser
  attr ← state.NSVG__getAttr@

  id ⇐ attr.id

  scale ⇐ NSVG__getAverageScale attr.xform
  strokeWidth ⇐ attr.strokeWidth × scale
  strokeDashOffset ⇐ attr.strokeDashOffset × scale
  strokeDashCount ⇐ attr.strokeDashCount
  strokeDashArray ⇐ attr.strokeDashArray × scale
  strokeLineJoin ⇐ attr.strokeLineJoin
  strokeLineCap ⇐ attr.strokeLineCap
  miterLimit ⇐ attr.miterLimit
  fillRule ⇐ attr.fillRule
  opacity ⇐ attr.opacity

  paths ⇐ p.plist
  p.SetPList ⟨⟩

  # Calculate shape bounds
  bounds ⇐ paths.bounds (⌊○(2⊸↑) ∾ ⌈○(2⊸↓))´ {𝕩.bounds}¨paths.list

  # Set fill
  fill ⇐ {
    type‿color‿gradient⇐@‿@‿@
    {0:
      type ↩ nsvGpaintType.nsvg_paint_none
    ;1:
      type ↩ nsvGpaintType.nsvg_paint_color
      color ↩ attr.fillColor∾attr.fillOpacity×255
    ;2:
      inv ← NSVG__xformInverse attr.xform
      localBounds ← NSVG__getLocalBounds paths‿inv
      gradient ↩ NSVG__createGradient⟨p, attr.fillGradient, localBounds, type⟩
      {𝕊:
        type ↩ nsvGpaintType.nsvg_paint_none
      }⍟(@⊸≡) gradient
    } attr.hasFill
  }

  # Set stroke
  stroke ⇐ {
    type‿color‿gradient⇐@‿@‿@
    {0: type ↩ nsvGpaintType.nsvg_paint_none
    ;1:
      type ↩ nsvGpaintType.nsvg_paint_color
      color ↩ attr.strokeColor∾⌊attr.strokeOpacity×255
    ;2:
      inv ← NSVG__xformInverse attr.xform
      localBounds ← NSVG__getLocalBounds paths‿inv
      gradient‿type ↩ NSVG__createGradient⟨p, attr.strokeGradient, localBounds⟩
      {𝕊:type ↩ nsvGpaintType.nsvg_paint_none}⍟(@⊸≡)gradient
    } attr.hasStroke
  }
  # Set flags
  flags ⇐ attr.visible⊑0‿nsvgflags.nsvg_flags_visible
}


NSVG__parseNameValue ← {𝕊p‿str:
  name‿value ← ∨`∘=⟜':'⊸(¬⊸/⋈1↓/)str
  name‿value {𝕩/˜(∨`⌾⌽∧∨`)¬𝕩∊' '∾@+9+↕5}¨↩

  NSVG__parseAttr p‿name‿value
}

NSVG__parseStyle ← {𝕊p‿str:
  {
    #                       Left and right trim
    NSVG__parseNameValue p⋈ 𝕩/˜(∨`⌾⌽∧∨`)¬𝕩∊' '∾@+9+↕5
  }¨ ';'((¬-˜⊢×·+`»⊸>)∘≠⊔⊢) str
}

# returns id
NSVG__parseUrl ← {𝕊str:
  ∧`∘≠⟜')'⊸/('#'=⊑)⊸↓"url("⊸∾⁼𝕩
}
hexchars ← ∾"0A"+⟜↕¨10‿6
NSVG__parseColorHex ← {𝕊str:
  ('#'≡⊑𝕩)∨6=≠1↓𝕩?    # 2 digit hex
    r‿g‿b ← (16⊸×⊸+˜´·⌽hexChars⊸⊐)˘3‿2⥊'#'∾⁼𝕩
  ;('#'≡⊑𝕩)∨3=≠1↓𝕩?    # 1 digit hex, e.g. #abc -> 0xccbbaa
    r‿g‿b ← 17×16×hexChars⊐'#'∾⁼𝕩
  ;128‿128‿128
}∘(-⟜(32×1="a{"⊸⍋))

# Parse rgb color. The pointer 'str' must point at "rgb(" (4+ characters).
# This function returns gray (rgb(128, 128, 128) == '#808080') on parse errors
# for backwards compatibility. Note: other image viewers return black instead.
NSVG__parseColorRGB ← {𝕊str:
  # clip values as the CSS spec requires
  0⌈255⌊⌊2.55⊸×⍟(∨´⌈⊸=) 3⥊⟜128⍟(=⟜≠) ToNums str
}

NSVG__parseColorName ← {𝕊str:
  3⥊color •ns.Has◶128‿•ns.Get str
}

NSVG__parseColor ← {
  '#'≡⊑𝕩?
    NSVG__parseColorHex 𝕩
; "rgb("≡4↑𝕩?
    NSVG__parseColorRGB 𝕩
;
  NSVG__parseColorName 𝕩
} ∨`∘≠⟜' '⊸/

NSVG__parseOpacity ← {𝕊str:
  1⌊0⌈•ParseFloat 𝕩
}

coordinateUnits ← >"px"‿"pt"‿"pc"‿"mm"‿"cm"‿"in"‿"em"‿"ex"‿"% "
coordUnitsValues ← ⟨
  nsvg_UNITS_PX
  nsvg_UNITS_PT
  nsvg_UNITS_PC
  nsvg_UNITS_MM
  nsvg_UNITS_CM
  nsvg_UNITS_IN
  nsvg_UNITS_PERCENT
  nsvg_UNITS_EM
  nsvg_UNITS_EX
  nsvg_UNITS_USER # default is last
⟩ ← ↕10
!coordUnitsValues≠⊸≡1+≠coordinateUnits

NSVG__parseUnits ← {𝕊units:
  coordUnitsValues⊏˜coordinateUnits⊐2↑units
}

NSVG__parseCoordinateRaw ← {𝕊str:
  unitMask ← ∾⟜0∧`⌾⌽∨˝⍉(2↕str)≡⌜○(<˘)coordinateUnits   # ISSUE HERE, ∊/⍷ being annoying
  units ⇐ NSVG__parseUnits unitMask/str
  value ⇐•ParseFloat unitMask¬⊸/str
}

NSVG__convertToPixels ← {𝕊p‿c‿orig‿length:
  attr ← p.NSVG__getAttr@
  {𝕩≡nsvg_units_user?           c.value
  ;𝕩≡nsvg_units_px?             c.value
  ;𝕩≡nsvg_units_pt?             c.value × p.dpi ÷ 72
  ;𝕩≡nsvg_units_pc?             c.value × p.dpi ÷ 6
  ;𝕩≡nsvg_units_mm?             c.value × p.dpi ÷ 25.4
  ;𝕩≡nsvg_units_cm?             c.value × p.dpi ÷ 2.54
  ;𝕩≡nsvg_units_in?             c.value × p.dpi
  ;𝕩≡nsvg_units_em?             c.value × attr.fontSize
  ;𝕩≡nsvg_units_ex?             c.value × attr.fontSize × 0.52 # x-height of Helvetica.
  ;𝕩≡nsvg_units_percent? orig + c.value × length ÷ 100
  ;                             c.value
  } c.units
  c.value
}

NSVG__parseCoordinate ← {𝕊p‿str‿orig‿length:
  coord ← NSVG__parseCoordinateRaw str
  NSVG__convertToPixels p‿coord‿orig‿length
}

NSVG__actualWidth  ← {𝕊p: p.viewWidth}
NSVG__actualHeight ← {𝕊p: p.viewHeight}

NSVG__actualLength ← {𝕊p:
  w ← NSVG__actualWidth p
  h ← NSVG__actualHeight p
  (√2)÷˜w+⌾(×˜)h
}

NSVG__parseStrokeDashArray ← {𝕊p‿str:
  # Handle "none"
  'n'≠⊑str?

    # Parse dashes
    strokeDashArray ← |{𝕊item:
      NSVG__parseCoordinate⟨p, item, 0, NSVG__actualLength p⟩
    }¨ (¬-˜⊢×·+`»⊸>)∘¬∘∊⟜(" ,"∾@+9+↕5)⊸⊔ str

    ⟨⟩⍟(1e¯6≥+´) strokeDashArray
;
  0
}

NSVG__parseLineCap ← {
  "butt":
    nsvglineCap.nsvg_cap_butt
  ;"round":
    nsvglineCap.nsvg_cap_round
  ;"square":
    nsvglineCap.nsvg_cap_square
  # TODO: handle inherit.
  ; nsvglineCap.nsvg_cap_butt
}

NSVG__parseLineJoin ← {
  "miter":
    nsvglineJoin.nsvg_join_miter
  ;"round":
    nsvglineJoin.nsvg_join_round
  ;"bevel":
    nsvglineJoin.nsvg_join_bevel
  # TODO: handle inherit.
  ; nsvglineJoin.nsvg_join_miter
}

NSVG__parseMiterLimit ← 0⌈•ParseFloat

NSVG__parseFillRule ← {
  "nonzero":
    nsvgfillRule.nsvg_fillrule_nonzero
  ;"evenodd":
    nsvgfillRule.nsvg_fillrule_evenodd
  # TODO: handle inherit.
  ; nsvgfillRule.nsvg_fillrule_nonzero
}

NSVG__parseMatrix ← {𝕊str:
  mat ← NSVG__parseTransformArgs str‿6
  "Incorrect amount of args to Matrix"!6≡≠mat
  mat
}

NSVG__parseTranslate ← {𝕊str:
  NSVG__xformSetTranslation 2↑NSVG__parseTransformArgs str‿2
}

NSVG__parseScale ← {𝕊str:
  args ← 2↑2⊸⥊⍟(1=≠)NSVG__parseTransformArgs str‿2
  {a‿b:a‿0‿0‿b‿0‿0} args
}

NSVG__parseSkewX ← {𝕊str: # str→xform
  args ← NSVG__parseTransformArgs str‿1
  "Skew accepts only 1 argument"!1=≠args
  NSVG__xformSetSkewX (π÷180)×⊑args
}

NSVG__parseSkewY ← {𝕊str:
  skew ← ⊑1↑NSVG__parseTransformArgs str‿1
  NSVG__xformSetSkewY skew×π÷180
}

NSVG__parseRotate ← {𝕊str:
  args ← 3↑NSVG__parseTransformArgs str‿3
  nsvg__xformIdentity NSVG__xformMultiply˜´⟨
    NSVG__xformSetTranslation -1↓args
    NSVG__xformSetRotation (π÷180)×⊑args
    NSVG__xformSetTranslation 1↓args
  ⟩
}
NSVG__xformSetRotation ← {𝕊a:
  [
    cs‿sn ← (•math.Cos⋈•math.Sin) a
    ⟨-sn ⋄ cs⟩
    0‿0
  ]
}



NSVG__parseTransform ← {𝕊str:

  p←+`-˝"()"=⌜str
  !∧´p∊↕2
  toParse ← ' '((¬-˜⊢×·+`»⊸>)∘(p∨≠)⊔⊢)str

  transforms ← {
     "matrix"   (⊣≡≠⊸↑)𝕩? NSVG__parseMatrix 𝕩
    ;"translate"(⊣≡≠⊸↑)𝕩? NSVG__parseTranslate 𝕩
    ;"scale"    (⊣≡≠⊸↑)𝕩? NSVG__parseScale 𝕩
    ;"rotate"   (⊣≡≠⊸↑)𝕩? NSVG__parseRotate 𝕩
    ;"skewX"    (⊣≡≠⊸↑)𝕩? NSVG__parseSkewX 𝕩
    ;"skewY"    (⊣≡≠⊸↑)𝕩? NSVG__parseSkewY 𝕩
    ; nsvg__xformIdentity
  }¨ toParse
  nsvg__xformIdentity NSVG__xformMultiply´ transforms
}

# returns int
# takes NSVGparser*‿str‿str
NSVG__parseAttr ← {𝕊p‿name‿value:
  attr ← p.NSVG__getAttr@ # NSVGattrib*
  attr≢@?
    r ← 1
    {"style":
      NSVG__parseStyle p‿value
    ;"display":
      {𝕊:attr.SetVisible 0}⍟⊢value≡"none"
      # Don't reset ->visible on display:inline, one display:none hides the whole subtree

    ;"fill":
      {"none"≡value?
        attr.SetHasfill 0
      ;"url("≡4↑value?
        attr.SetHasfill 2
        NSVG__parseUrl attr.fillGradient‿value
      ;
        attr.SetHasfill 1
        attr.SetFillColor NSVG__parseColor value
      }
    ;"opacity":
      attr.SetOpacity NSVG__parseOpacity value
    ;"fill-opacity":
      attr.SetFillOpacity NSVG__parseOpacity value
    ;"stroke":
      {value≡"none"?
        attr.SetHasStroke 0
      ;"url("≡4↑value?
        attr.SetHasStroke 2
        NSVG__parseUrl attr.strokeGradient‿value
      ;
        attr.SetHasStroke 1
        attr.SetStrokeColor NSVG__parseColor value
      }
    ;"stroke-width":
      attr.SetStrokeWidth NSVG__parseCoordinate ⟨p⋄value⋄0⋄NSVG__actualLength p⟩
    ;"stroke-dasharray":
      attr.SetStrokeDashCount NSVG__parseStrokeDashArray p‿value‿attr.strokeDashArray
    ;"stroke-dashoffset":
      attr.SetStrokeDashOffset NSVG__parseCoordinate⟨p, value, 0, NSVG__actualLength p⟩
    ;"stroke-opacity":
      attr.SetStrokeOpacity NSVG__parseOpacity value
    ;"stroke-linecap":
      attr.SetStrokeLineCap NSVG__parseLineCap value
    ;"stroke-linejoin":
      attr.SetStrokeLineJoin NSVG__parseLineJoin value
    ;"stroke-miterlimit":
      attr.SetMIterLimit NSVG__parseMiterLimit value
    ;"fill-rule":
      attr.SetFillRule NSVG__parseFillRule value
    ;"font-size":
      attr.SetFontSize NSVG__parseCoordinate⟨p, value, 0, NSVG__actualLength p⟩
    ;"transform":
      xform ← NSVG__parseTransform value
      attr.SetXForm attr.xform NSVG__xformMultiply˜ xform
    ;"stop-color":
      attr.SetStopColor NSVG__parseColor value
    ;"stop-opacity":
      attr.SetStopOpacity NSVG__parseOpacity value
    ;"offset":
      attr.SetStopOffset NSVG__parseCoordinate p‿value‿0‿1
    ;"id":
      attr.SetID value
    ;
      r↩0
    } name
    r
;
  0
}


NSVG__cubicBezTo ← {𝕊p‿cpx1‿cpy1‿cpx2‿cpy2‿x‿y:
  p.npts > 0?
    p.NSVG__addPoint cpx1‿cpy1
    p.NSVG__addPoint cpx2‿cpy2
    p.NSVG__addPoint x‿y
  ;@
}

nsvgPathDefault ← ⟨
  ⟨⟩       # pts    # float*             # Cubic bezier points: x0,y0, [cpx1,cpx1,cpx2,cpy2,x1,y1], ...
  0        # npts   # int                # Total number of bezier points.
  0        # closed # char               # Flag indicating if shapes should be treated as closed.
  0‿0‿0‿0  # bounds # float[4]           # Tight bounding box of the shape [minx,miny,maxx,maxy].
  @        # next   # struct NSVGpath*   # Pointer to next path, or NULL if last element.
⟩

NSVG__addPath ← {𝕊p‿closed:
  attr ← p.NSVG__getAttr
  path ← NULL
  float bounds[4];
  float* curve;
  int i;

  p.npts ≥ 4?

    p.NSVG__lineTo⍟closed 2↑p.pts

    # Expect 1 + N*3 points (N = number of cubic bezier segments).
    1=3|p->npts?

      path ← nsvgPathDefault

      path.pts ← 0⥊˜p.npts×2
      path.closed ← closed
      path.npts ← p.npts

      # Transform path.
      {𝕊:
        NSVG__xformPoint(&path->pts[i*2], &path->pts[i*2+1], p->pts[i*2], p->pts[i*2+1], attr->xform);
      }¨↕p->npts

          curves ← NSVG__xformPoint˘˘path.pts⊏˜⍉0‿1+⌜2×1+⌊‿3⥊↕1+path.npts

      # Find bounds
      for (i = 0; i < path.npts-1; i += 3) {
        NSVG__curveBounds bounds‿⟨path.pts⊑˜i×2⟩
        path.bounds (⌊○(2⊸↑)∾⌈○(2⊸↓))⍟(i=0)↩ bounds
      }

      path.next ← p.plist
      p.plist ← path
  ;@
}

NSVG__parseRect ← {𝕊p‿attr: # NSVGParser‿*str
  x ← 0
  y ← 0
  w ← 0
  h ← 0
  rx ← ¯1 # marks not set
  ry ← ¯1

  {𝕊attribute‿val:
    {𝕤
      attribute≡"x"?      x ↩  NSVG__parseCoordinate⟨p, val, p.viewMinx, NSVG__actualWidth p⟩
      attribute≡"y"?      y ↩  NSVG__parseCoordinate⟨p, val, p.viewMiny, NSVG__actualHeight p⟩
      attribute≡"width"?  w ↩  NSVG__parseCoordinate⟨p, val, 0,          NSVG__actualWidth p⟩
      attribute≡"height"? h ↩  NSVG__parseCoordinate⟨p, val, 0,          NSVG__actualHeight p⟩
      attribute≡"rx"?    rx ↩ |NSVG__parseCoordinate⟨p, val, 0,          NSVG__actualWidth p⟩
      attribute≡"ry"?    ry ↩ |NSVG__parseCoordinate⟨p, val, 0,          NSVG__actualHeight p⟩
      ;@
    }⍟¬NSVG__parseAttr⟨p⟩∾𝕩
  }˘⍉attr

  rx‿ry (2⥊⌈´)⍟(∨´<⟜0)↩
  rx‿ry ⌈↩ 0
  rx‿ry ⌊↩ w‿h÷2

  {𝕤
    p.NSVG__resetPath@
    {∨´rx‿ry<1e¯5‿1e¯4?
      p.NSVG__moveTo x‿y
      p.NSVG__lineTo⟨x+w, y⟩
      p.NSVG__lineTo⟨x+w, y+h⟩
      p.NSVG__lineTo⟨x, y+h⟩
    ;
      # Rounded rectangle
      p.NSVG__moveTo⟨x+rx, y⟩
      p.NSVG__lineTo⟨(x+w)-rx, y⟩
      p.NSVG__cubicBezTo⟨(x+w)-rx×¬nsvg_KAPPA90, y, x+w, y+ry×¬nsvg_KAPPA90, x+w, y+ry⟩
      p.NSVG__lineTo⟨x+w, (y+h)-ry⟩
      p.NSVG__cubicBezTo⟨x+w, (y+h)-ry×¬nsvg_KAPPA90, (x+w)-rx×¬nsvg_KAPPA90, y+h, (x+w)-rx, y+h⟩
      p.NSVG__lineTo⟨x+rx, y+h⟩
      p.NSVG__cubicBezTo⟨(x+rx)×¬nsvg_KAPPA90, y+h, x, (y+h)-ry×¬nsvg_KAPPA90, x, (y+h)-ry⟩
      p.NSVG__lineTo⟨x, y+ry⟩
      p.NSVG__cubicBezTo⟨x, (y+ry)×¬nsvg_KAPPA90, (x+rx)×¬nsvg_KAPPA90, y, x+rx, y⟩
    }

    p.NSVG__addPath p‿1

    p.NSVG__addShape
  }⍟⊢∧´0≠w‿h
}

NSVG__parseCircle ← {𝕊p‿attr: # attr is x‿2≡≢𝕩 of strings
  cx ← 0
  cy ← 0
  r ← 0

  {𝕊a‿b:
    {𝕊:
      {𝕊:cx ↩ NSVG__parseCoordinate ⟨p, b, p.NSVG__actualOrigX@, p.NSVG__actualWidth@⟩   }⍟⊢a≡"cx"
      {𝕊:cy ↩ NSVG__parseCoordinate ⟨p, b, p.NSVG__actualOrigY@, NSVG__actualHeight p⟩  }⍟⊢a≡"cy"
      {𝕊: r ↩ |NSVG__parseCoordinate ⟨p, b, 0, NSVG__actualLength p⟩                   }⍟⊢a≡"r"
    }⍟¬NSVG__parseAttr p‿a‿b
  }˘attr

  r > 0?
    p.NSVG__resetPath@
    p.NSVG__moveTo ⟨cx+r, cy⟩
    NSVG__cubicBezTo ⟨p, cx+r, cy+r×nsvg_KAPPA90, cx+r×nsvg_KAPPA90, cy+r, cx, cy+r⟩
    NSVG__cubicBezTo ⟨p, cx-r×nsvg_KAPPA90, cy+r, cx-r, cy+r×nsvg_KAPPA90, cx-r, cy⟩
    NSVG__cubicBezTo ⟨p, cx-r, cy-r×nsvg_KAPPA90, cx-r×nsvg_KAPPA90, cy-r, cx, cy-r⟩
    NSVG__cubicBezTo ⟨p, cx+r×nsvg_KAPPA90, cy-r, cx+r, cy-r×nsvg_KAPPA90, cx+r, cy⟩

    NSVG__addPath p‿1

    NSVG__addShape p
  ;
    @
}

NSVG__parseEllipse {𝕊p‿attr: # attr is x‿2≡≢𝕩 of strings
  cx‿cy‿rx‿ry ← 4⥊0

  {𝕊a‿b:
    {𝕊:
       a≡"cx"? cx ↩  NSVG__parseCoordinate⟨p, b, p.NSVG__actualOrigX@, NSVG__actualWidth p⟩
      ;a≡"cy"? cy ↩  NSVG__parseCoordinate⟨p, b, p.NSVG__actualOrigY@, NSVG__actualHeight p⟩
      ;a≡"rx"? rx ↩ |NSVG__parseCoordinate⟨p, b, 0, NSVG__actualWidth p⟩
      ;a≡"ry"? ry ↩ |NSVG__parseCoordinate⟨p, b, 0, NSVG__actualHeight p⟩
    }⍟¬NSVG__parseAttr p‿a‿b
  }˘attr

  ∧´rx‿ry > 0?
    NSVG__resetPath p

    NSVG__moveTo ⟨p, cx+rx, cy⟩
    NSVG__cubicBezTo⟨p, cx+rx, cy+ry×nsvg_KAPPA90, cx+rx×nsvg_KAPPA90, cy+ry, cx, cy+ry⟩
    NSVG__cubicBezTo⟨p, cx-rx×nsvg_KAPPA90, cy+ry, cx-rx, cy+ry×nsvg_KAPPA90, cx-rx, cy⟩
    NSVG__cubicBezTo⟨p, cx-rx, cy-ry×nsvg_KAPPA90, cx-rx×nsvg_KAPPA90, cy-ry, cx, cy-ry⟩
    NSVG__cubicBezTo⟨p, cx+rx×nsvg_KAPPA90, cy-ry, cx+rx, cy-ry×nsvg_KAPPA90, cx+rx, cy⟩

    NSVG__addPath p‿1

    NSVG__addShape p
  ;@
}

NSVG__parseLine ← {𝕊p‿attr:
  x1‿y1‿x2‿y2 ← 4⥊0

  {𝕊a‿b:
    {𝕊:
       a≡"x1"? x1 ↩ NSVG__parseCoordinate⟨p, b, p.NSVG__actualOrigX@, NSVG__actualWidth p⟩
      ;a≡"y1"? y1 ↩ NSVG__parseCoordinate⟨p, b, p.NSVG__actualOrigY@, NSVG__actualHeight p⟩
      ;a≡"x2"? x2 ↩ NSVG__parseCoordinate⟨p, b, p.NSVG__actualOrigX@, NSVG__actualWidth p⟩
      ;a≡"y2"? y2 ↩ NSVG__parseCoordinate⟨p, b, p.NSVG__actualOrigY@, NSVG__actualHeight p⟩
    }⍟¬NSVG__parseAttr p‿a‿b
  }˘attr

  NSVG__resetPath p

  NSVG__moveTo⟨p, x1, y1⟩
  NSVG__lineTo⟨p, x2, y2⟩

  NSVG__addPath p‿0

  NSVG__addShape p
}


ParsePath ← (⊑¨≍˘ToNums¨)1↓(+`>⟜»)∘∊⟜letters⊸⊔

NSVG__parsePoly ← {p‿attr‿closeFlag: # NSVGparser*, str*, int
  nargs‿npts ← 0

  p.NSVG__resetPath@

  {𝕊a‿b:
    {𝕊:
      ⟨start⟩‿moves ← 1(↑⋈↓)ParsePath b
      p.NSVG__moveTo start
      p.NSVG__lineTo¨moves
    }⍟⊢ (a≡"points")∧¬NSVG__parseAttr p‿a‿b
    @
  }˘attr

  NSVG__addPath⟨p, closeFlag⟩

  NSVG__addShape p
}

NSVG__parseEllipse ← •Show
NSVG__parseGradient ← •Show
NSVG__parseGradientStop ← •Show
NSVG__parseAttribs ← •Show
NSVG__parsePath ← •Show

NSVG__ParseSVG ← @∘{
  "viewBox"𝕊𝕩: state.SetViewRec ToNums 𝕩
  ;"xmlns"𝕊𝕩: !"http://www.w3.org/2000/svg"≡𝕩
  ;"width"𝕊𝕩: state.SetImageWidth 𝕩
  ;"height"𝕊𝕩: state.SetImageHeight 𝕩
  ;"preserveAspectRatio"𝕊𝕩:
    {
      ∨´"none"⍷𝕩?
        # No uniform scaling
        state.SetAlignType nsvg_align_none
    ;
      # Parse X and Y align
      state.SetAlignPos ⟨
        {∨´"xMin"⍷𝕩? nsvg_align_min
        ;∨´"xMid"⍷𝕩? nsvg_align_mid
        ;∨´"xMax"⍷𝕩? nsvg_align_max
        ;@}𝕩
        {∨´"yMin"⍷𝕩? nsvg_align_min
        ;∨´"yMid"⍷𝕩? nsvg_align_mid
        ;∨´"yMax"⍷𝕩? nsvg_align_max
        ;@}𝕩
      ⟩
      # Parse meet/slice
      state.SetAlignType nsvg_align_meet‿nsvg_align_slice⊑˜∨´𝕩⍷"slice"
    }𝕩
  ;"fill"𝕊𝕩: !𝕩≡"none"
}´¨<˘∘⍉

state ← CreateState@

Start ← •Out∘∾⟜" started"⊢{
  state.defsFlag?
    # Skip everything but gradients in defs
    {"linearGradient"𝕊𝕩:
      NSVG__parseGradient state‿𝕩‿nsvGpaintType.nsvg_paint_linear_gradient
    ;"radialGradient"𝕊𝕩:
      NSVG__parseGradient state‿𝕩‿nsvGpaintType.nsvg_paint_radial_gradient
    ;"stop"𝕊𝕩:
      NSVG__parseGradientStop state‿𝕩
    }´𝕨‿𝕩

  ;"g"𝕊𝕩:
      state.NSVG__pushAttr@
      NSVG__parseAttribs state‿𝕩
  ;"path"𝕊𝕩:
    {𝕊: # Do not allow nested paths.
      state.NSVG__pushAttr@
      NSVG__parsePath state‿𝕩
      state.NSVG__popAttr@
    }⍟state.pathFlag state
  ;"rect"𝕊𝕩:
    state.NSVG__pushAttr@
    NSVG__parseRect state‿𝕩
    state.NSVG__popAttr@
  ;"circle"𝕊𝕩:
    state.NSVG__pushAttr@
    NSVG__parseCircle state‿𝕩
    state.NSVG__popAttr@
  ;"ellipse"𝕊𝕩:
    state.NSVG__pushAttr@
    NSVG__parseEllipse state‿𝕩
    state.NSVG__popAttr@
  ;"line"𝕊𝕩:
    state.NSVG__pushAttr@
    NSVG__parseLine state‿𝕩
    state.NSVG__popAttr@
  ;"polyline"𝕊𝕩:
    state.NSVG__pushAttr@
    NSVG__parsePoly state‿𝕩‿0
    state.NSVG__popAttr@
  ;"polygon"𝕊𝕩:
    state.NSVG__pushAttr@
    NSVG__parsePoly state‿𝕩‿1
    state.NSVG__popAttr@
  ;"linearGradient"𝕊𝕩:
    NSVG__parseGradient state‿𝕩‿nsvGpaintType.nsvg_paint_linear_gradient
  ;"radialGradient"𝕊𝕩:
    NSVG__parseGradient state‿𝕩‿nsvGpaintType.nsvg_paint_radial_gradient
  ;"stop"𝕊𝕩:
    NSVG__parseGradientStop state‿𝕩
  ;"defs"𝕊𝕩:
    state.SetDefsFlag 1
  ;"svg"𝕊𝕩:
    NSVG__ParseSVG 𝕩
  ;@
}

End ← •Out∘∾⟜" Ended"⊢{
   "g"𝕊args: state.NSVG__popAttr@
  ;"path"𝕊args: state.SetPathFlag 0
  ;"defs"𝕊args: state.SetDefsFlag 0
  ;@
}


Start _ParseSVG_ End •FChars "logo.svg"