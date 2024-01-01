# Binding for sox's resample library

u ← "u64"
soxR ← "/home/brian/Downloads/soxr-0.1.3-Source/src/libsoxr.so" •FFI ⟨
  u,"soxr_oneshot","f64","f64","u32"
  "*f32",u,u
  "&f32",u,"&u64:i32"
  u,u,u
⟩

# Resample pcm data 𝕩 from frequency fIn to frequency fOut.
{ iFr‿oFr 𝕊 𝕩:
  {
    oMax ← ⌈ (oFr÷iFr) × iLen←≠𝕩 # Input and maximum output lengths
    s‿out‿oLen ← SoxR ⟨iFr,oFr,1, 𝕩,iLen,0, oMax⥊0,oMax,⟨1,0⟩, 0,0,0⟩
    ! 0 = s
    (⊑oLen)↑out
  }⎉1⍟(iFr≠oFr) 𝕩
}