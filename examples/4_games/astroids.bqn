# MIT License
# Copyright (c) 2024 David Zwitser
⟨c⇐color, win⇐window, font, d⇐draw, m⇐mouse, key, rayffi⇐raylib⟩←r←•Import "../../rayed.bqn"
Sin‿Cos ← •math

frame ← time ← dt ← deltatime ← 1
center ← w‿h ← size ← 0‿0

states ← {start‿play‿reset‿dying ⇐ ↕4}

Lfo ← {𝕊 step‿size:
  size × Sin time × step × π÷2
}

Rand ← {𝕊range: •rand.Range¨𝕩;
  	 res𝕊range: •rand.Range¨⌾(res⊸×)𝕩
}

Player ← {type ⇐ 𝕤
  pos ← center, vel ← 0‿0, rot ← 0, life ⇐ 3
  rocket_power ← 0.05, rot_speed ← 0.02, size ← 20, fric ← 0.995
  color ← c.white
  boosting ← 0

  base_shape ← ⍉[0.2‿0.3, 0‿0, 0.5‿1.5, 1‿0, 0.8‿0.3]
  base_flame ← ⍉[0.5‿¯0.2, 0.2‿0.3, 0.8‿0.3]
  base_center ← (+˝÷≠)⍉base_shape
  draw_shape ← base_shape

  Orient ⇐ {𝕊: rot +↩ π×rot_speed×𝕩}
  Boost  ⇐ {
		{
			vel +↩ rocket_power × 𝕩×-∘Sin⊸⋈⟜Cos rot
		}⍟⊢ boosting ↩ 𝕩
	}
  GetBulletInfo  ⇐ {𝕊: rot⋈˜2⊏˘draw_shape}

  Update ⇐ {𝕊: pos ({x‿y: (w|x)‿(h|y)}+)↩ vel, vel ×↩ fric }
  ShapeShape ← {pos⊸+˘ size⊸× (Sin⊸(⋈˜≍-⊸⋈)⟜Cos rot)+˝∘×⎉2‿1 -⟜𝕨˘ 𝕩}

  Draw ⇐ {𝕊:
    draw_shape ↩ ⍉base_center ShapeShape ⍉base_shape
		c.white d.Line ⍉˘⍉1⊸⌽⊸≍ ⍉draw_shape

    {𝕊:
      draw_flame ← base_center ShapeShape ⍉base_flame
    	c.white d.Line ⍉˘⍉1⊸⌽⊸≍ draw_flame
      ;@
    }⍟⊢boosting ∧ 5<10|frame
  }
  CollBody ⇐ {𝕊: draw_shape}
  Hit ⇐ {𝕊: life (4|-)↩ 1, vel↩0‿0}
  Dying ⇐ {𝕊: color ↩ (10>20|frame)⊑⟨c.white,c.black⟩}
  CenterMe ⇐ {𝕊: pos↩center}
}

Astroid ← {𝕊info: type ⇐ 𝕤
  life ⇐ 1
  max_size ← 6, scale ← 10
  size‿pos ← {info≡@ ?
      ⟨1 + •rand.Range max_size - 1
       center+100 + Rand w‿h⟩
    ; info
  }
  vel ← 0.7×{(𝕩÷2)-˜1000 Rand⋈˜𝕩} max_size-size

  CreateShape ← {𝕊 v_count‿off_chance‿off_size:
    Circle ← {-∘Sin⊸⋈⟜Cos¨ 𝕩÷˜π×2 × 1+ ↕𝕩}
    {𝕩 - (10 Rand⋈˜ off_size) × 0≡•rand.Range off_chance }¨  Circle v_count
  }
  shape ← >scale×size × CreateShape 10‿3‿0.8
  shape_center ← (+˝÷≠) shape

  Update ⇐ {𝕊: pos (w‿h|+) ↩ vel}

  Draw ⇐ {𝕊:
    draw_shape ← pos +⎉1 shape
    c.white d.Line ⍉˘⍉1⊸⌽⊸≍ draw_shape
  }
  CollBody ⇐ {𝕊: (pos+shape_center)‿(scale×size) }
  Split ⇐ {𝕊: life ↩ 0, ⋈˜(size-1)‿pos}
}
Bullet ← {pos‿vel: type ⇐ 𝕤
  life ⇐ 1
  size ← 2

  Update ⇐ {𝕊: pos +↩ vel}
  Draw   ⇐ {𝕊: c.white d.Rectangle ⌊pos (-≍+)∾˜ size÷2}
  CollBody ⇐ {𝕊: pos≍2⥊size}
  Kill ⇐ {𝕊: life ↩ 0}
}

_getUI ← {font _𝕣 lives:
  c.white‿font‿30 d.Text ⟨w‿h×0.01⋄lives∾" lives"⟩
}

Resize ← {𝕊 world:
  w‿h ↩ size ↩ win.GetSize@, center ↩ size÷2
}
Input ← {𝕊 world:
  player←⊑world
  {key.IsDown key.right ? player.Orient 1; @}
  {key.IsDown key.left ? player.Orient ¯1; @}
  {key.IsDown key.up ? player.Boost 1; player.Boost 0}
  {key.IsPressed key.space ?
    pos‿rot ← player.GetBulletInfo @
    world ∾↩Bullet pos⋈7×-∘Sin⊸⋈⟜Cos rot
    ; @
  }
  world
}
Collision ← {𝕊 state‿world:
  bullets ← {𝕩 ⊑ world}¨ / {𝕩.type ≡ bullet}¨ world
  astroids ← {𝕩 ⊑ world}¨ / {𝕩.type ≡ astroid}¨ world
  player ← ⊑world

  new_astroids ← ⟨⟩
  BullHit ← {bullet 𝕊 astroid:
    rayffi.CheckCollisionCircleRec 𝕩.CollBody⊸∾<𝕨.CollBody@?
      bullet.Kill @
      new_astroids ∾↩ astroid.Split @
    ; @
  }
  bullets BullHit⌜ astroids
  world ∾↩ Astroid¨ new_astroids

  PlayerHit ← {player𝕊astroid:
    p_points ← player.CollBody @
    a_bod ← astroid.CollBody @
    +´ {rayffi.CheckCollisionPointCircle 𝕩<⊸∾a_bod}˘ ⍉p_points
  }
  player_is_hit ← 0 < +´ player PlayerHit⌜ astroids
  {player_is_hit ? player.Hit @, state↩states.dying;@}
  {player.life ≡ 0 ? state ↩ states.reset ;@}

  state‿world
}

Run ← {state‿world‿fontBQN‿DrawUI:
  {state ≡ states.start ?
    size ← 40
    {
      (150|frame)>50?
      c.white‿fontBQN‿size d.Text {(center - (size × 0.5× ≠𝕩)‿size÷2)‿𝕩} "space to s↑art"
      ;@
    }
    {key.IsDown key.space ? state ↩ states.play, frame↩0 ; @}

    state‿world
  ; state ≡ states.play ?

    {𝕩.Draw @}¨ world
    { frame<200?
      size ← 40
      c.white‿fontBQN‿size d.Text {(center - (size × 0.5× ≠ 𝕩)‿size÷2)‿𝕩} •Fmt ⌈3-3×frame÷200
      ;
      world Input↩
      world {0<𝕩.life}¨⊸/ ↩
      {𝕩.Update @}¨ world
    }
    DrawUI •Fmt (⊑world).life

    {(+´{𝕩.type≡astroid}¨world)≡0?world∾↩(Astroid 0);@}

    state‿world Collision↩
    {state ≡ states.dying ? frame↩0; @}

    state‿world

  ; state ≡ states.dying ?
    {frame < 100 ?
      DrawUI •Fmt (⊑world).life
      (⊑world).Dying @
      {𝕩.Draw@}¨ world
      state‿world
    ;
      (⊑world).CenterMe@
      # world ↩ CreateWorld 10‿(⊑world)
      state ↩ states.play
      state‿world
    }

  ; state ≡ states.reset ?
    world ↩ CreateWorld 10‿@
    state ↩ states.start
    state‿world
  ;state‿world}
}

CreateWorld ← {𝕊 astroid_amount‿prev_player:
  {prev_player≡@? prev_player ↩ Player @; @}
  astroids ← Astroid¨ astroid_amount⥊@
  prev_player∾astroids
}

{𝕊:
  Resize ⟨⟩
  fontBQN ← font.LoadBQN 80
  DrawUI ← fontBQN _getUI
  {𝕊 state‿world:
    frame +↩ 1, time +↩ dt ← deltatime ← rayffi.GetFrameTime⟨⟩
    { rayffi.IsWindowResized⟨⟩ ? Resize world ; @}

    rayffi.DrawFPS 20‿50
    Run state‿world‿fontBQN‿DrawUI
  } d._withCanvas⟜c.black •_While_ (¬win.ShouldClose) states.reset‿⟨⟩
} win._openAs "Astroids"
