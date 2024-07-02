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

NSVG__parseTransformArgs ← {𝕊str‿maxNa:
  ("Incorrect amount of args"!maxNa≡≠)⊸⊢ ToNums str
}

NSVG__parseSkewX ← {𝕊str: # str→int‿xform
  args ← NSVG__parseTransformArgs str‿1
  NSVG__xformSetSkewX π×180÷˜⊑args
}

NSVG__xformSetTranslation ← (⥊=⌜˜↕2)⊸∾

# returns NSVGparser
CreateState ← {𝕊:

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

NSVG__parseColorHex ← (∾"0A"+⟜↕¨10‿6){hexChars𝕊str:
	('#'≡⊑𝕩)∨6=≠1↓𝕩?		# 2 digit hex
		r‿g‿b ← (16⊸×⊸+˜´·⌽𝕨⊸⊐)˘3‿2⥊'#'∾⁼𝕩
	;('#'≡⊑𝕩)∨3=≠1↓𝕩?		# 1 digit hex, e.g. #abc -> 0xccbbaa
		r‿g‿b ← 17×16×𝕨⊐'#'∾⁼𝕩
	;128‿128‿128
}∘(-⟜(32×1="a{"⊸⍋))

# Parse rgb color. The pointer 'str' must point at "rgb(" (4+ characters).
# This function returns gray (rgb(128, 128, 128) == '#808080') on parse errors
# for backwards compatibility. Note: other image viewers return black instead.
NSVG__parseColorRGB ←{𝕊str:
  int i;
  rgbi[3]
  float rgbf[3];
  # try decimal integers first
  if (sscanf(str, "rgb(%u, %u, %u)", &rgbi[0], &rgbi[1], &rgbi[2]) != 3) {
    # integers failed, try percent values (float, locale independent)
    delimiter ← ",,)"
    str "rgb("⊸∾⁼↩ # skip "rgb("
    {
      str ∨`∘¬∘NSVG__isspace⊸/↩   # skip leading spaces
      str '+'⊸≡⟜⊑⊸↓↩ # skip '+' (don't allow '-')

      str≢⟨⟩?
        rgbf[i] ↩ NSVG__atof str

        # Note 1: it would be great if nsvg__atof() returned how many
        # bytes it consumed but it doesn't. We need to skip the number,
        # the '%' character, spaces, and the delimiter ',' or ')'.

        # Note 2: The following code does not allow values like "33.%",
        # i.e. a decimal point w/o fractional part, but this is consistent
        # with other image viewers, e.g. firefox, chrome, eog, gimp.

        str ∨`∘¬∘NSVG__isdigit⊸/↩
        str ∨`∘¬∘∊⟜('0'+↕10)⊸/↩ # skip integer part
        {𝕤
          str↓˜↩1
          "error: no digit after '.'"!str⊑⊸∊'0'+↕10
          str ∨`∘¬∘∊⟜('0'+↕10)⊸/↩
        }⍟⊢'.'≡⊑str
        !'%'≡⊑str
        str↓˜↩1
        str ∨`∘¬∘∊⟜(' '∾@+9+↕5)⊸/↩
        !str ⊑⊸= i⊑delimiter
        str∾⁼˜i⊑delimiter
    ;
      @
    }¨ (+`×¬)⊸-∘=⟜','⊸⊔ str
    rgbi ← {i=3?
      ⌊0.5+2.55×rgbf
    ;
      3⥊128
    }
  }
  # clip values as the CSS spec requires
  0⌈255⌊rgbi
}

NSVG__parseColor ← {
  '#'≡⊑𝕩?
    NSVG__parseColorHex 𝕩
; "rgb("≡4↑𝕩?
    NSVG__parseColorRGB 𝕩
;
  NSVG__parseColorName 𝕩
} ∨`∘≠⟜' '⊸/


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
      attr.SetXForm attr.xform NSVG__xformPremultiply xform
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


NSVG__parseRect ← {𝕊p‿attr: # NSVGParser‿*str
	x ← 0
	y ← 0
	w ← 0
	h ← 0
	rx ← ¯1 # marks not set
	ry ← ¯1

	{𝕊attribute‿val:
		{𝕤
			attribute≡"x"?      x ↩  NSVG__parseCoordinate⟨p, val, NSVG__actualOrigX p, NSVG__actualWidth p⟩
			attribute≡"y"?      y ↩  NSVG__parseCoordinate⟨p, val, NSVG__actualOrigY p, NSVG__actualHeight p⟩
			attribute≡"width"?  w ↩  NSVG__parseCoordinate⟨p, val, 0,                    NSVG__actualWidth p⟩
			attribute≡"height"? h ↩  NSVG__parseCoordinate⟨p, val, 0,                    NSVG__actualHeight p⟩
			attribute≡"rx"?    rx ↩ |NSVG__parseCoordinate⟨p, val, 0,                    NSVG__actualWidth p⟩
			attribute≡"ry"?    ry ↩ |NSVG__parseCoordinate⟨p, val, 0,                    NSVG__actualHeight p⟩
      ;@
    }⍟¬NSVG__parseAttr⟨p⟩∾𝕩
	}˘⍉attr

	{𝕊:rx ↩ ry}⍟⊢ (rx<0) ∧ ry>0
	{𝕊:ry ↩ rx}⍟⊢ (ry<0) ∧ rx>0
	{𝕊:rx ↩ 𝕩}⍟(rx⊸<) 0
	{𝕊:ry ↩ 𝕩}⍟(ry⊸<) 0
	{𝕊:rx ↩ 𝕩}⍟(rx⊸>) w÷2
	{𝕊:ry ↩ 𝕩}⍟(ry⊸>) h÷2

	{𝕤
		NSVG__resetPath p
		{∨´rx‿ry<1e¯5‿1e¯4?
			NSVG__moveTo⟨p, x, y⟩
			NSVG__lineTo⟨p, x+w, y⟩
			NSVG__lineTo⟨p, x+w, y+h⟩
			NSVG__lineTo⟨p, x, y+h⟩
		;
			# Rounded rectangle
			NSVG__moveTo⟨p, x+rx, y⟩
			NSVG__lineTo⟨p, x+w-rx, y⟩
			NSVG__cubicBezTo⟨p, (x+w)-rx×¬NSVG_KAPPA90, y, x+w, y+ry×¬nsvg_KAPPA90, x+w, y+ry⟩
			NSVG__lineTo⟨p, x+w, (y+h)-ry⟩
			NSVG__cubicBezTo⟨p, x+w, (y+h)-ry×¬nsvg_KAPPA90, (x+w)-rx×¬nsvg_KAPPA90, y+h, (x+w)-rx, y+h⟩
			NSVG__lineTo⟨p, x+rx, y+h⟩
			NSVG__cubicBezTo⟨p, (x+rx)×¬nsvg_KAPPA90, y+h, x, (y+h)-ry×¬nsvg_KAPPA90, x, (y+h)-ry⟩
			NSVG__lineTo⟨p, x, y+ry⟩
			NSVG__cubicBezTo⟨p, x, (y+ry)×¬nsvg_KAPPA90, (x+rx)×¬nsvg_KAPPA90, y, x+rx, y⟩
		}

		p.NSVG__addPath p‿1

		p.NSVG__addShape
	}⍟⊢∧´0≠w‿h
}

NSVG__parseCircle ← •Show
NSVG__parseEllipse ← •Show
NSVG__parseLine ← •Show
NSVG__parsePoly ← •Show
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