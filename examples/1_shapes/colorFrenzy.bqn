⟨c⇐color,window,d⇐draw,m⇐mouse⟩←r←•Import "../../raylib.bqn"

frame ← 0

colors ← [
 c.moccasin, c.navy, c.oldlace, c.olivedrab, c.orange
]

scale ← 2
step ← 0.2÷5

Start ← {𝕊tex:
    font ← r.font.LoadBQN 100

    size ← ⌊(window.GetSize @) ÷ scale
    center ← ⌊size÷2
    w‿h ← size
•Show ≍⟨1,2⟩
    PerPixel ← {
        colors⊏˜(≠colors)|¯1+⌊(÷⟜h≠colors)×𝕩-frame
    }
    pixels ← +˝⌾(×˜)center-˜{𝕩+𝕩×5÷˜•math.Sin frame×step}w(⌊|≍÷˜)size⥊↕×´size
    PerFrame ← {𝕊tex:
        r.rayffi.UpdateTexture tex⋈⥊PerPixel pixels

        c.white‿tex‿scale‿0 d.Texture 0‿0
        c.white‿font‿30 d.Text 20‿20⋈•Repr∘window.fps.Get⊸∾" FPS"
        
        frame+↩1
        𝕩
    }d._withCanvas_ c.black
    
    App ← PerFrame •_While_(¬window.ShouldClose)

    App r.texture._WithImage (size∾4)⥊255
}


0.5 Start window._openAs "test"