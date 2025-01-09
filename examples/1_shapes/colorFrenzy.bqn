# Credit to coolpeanut (discord username)
# they are the original creator of this example

⟨c⇐color,window,d⇐draw,m⇐mouse⟩←r←•Import "../../rayed.bqn"

frame ← 0

colors ← ¯128+256|128+[
 c.moccasin, c.navy, c.oldlace, c.olivedrab, c.orange
]

scale ← 2
step ← 0.2÷5

Start ← {𝕊tex:
    font ← r.font.LoadBQN 100

    size ← ⌽⌈window.GetSize⊸÷scale
    pixels ← +˝⌾(×˜)size+˜⁼⊸-⍉⁼>↕size

    PerFrame ← {𝕊tex:
        r.raylib.UpdateTextureRaw ⟨tex
            colors(≠⊸|⊏⊣)⌊(colors≠⊸÷⌈´size)×frame-pixels×1+5÷˜•math.Sin frame×step
        ⟩
        c.white‿tex‿scale‿0 d.Texture 0‿0
        c.white‿font‿30 d.Text 20‿20⋈•Repr∘window.GetFPS⊸∾" FPS"
        frame+↩1
    }⊸⊢d._withCanvas⟜c.black

    App ← PerFrame •_While_(¬window.ShouldClose)
    App r.texture._WithImage (size∾4)⥊255
}

Start window._openAs "test"
