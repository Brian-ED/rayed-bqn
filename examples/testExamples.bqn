# Run every example and show errors
d←•Show ('d'=•file.Type¨)⊸/ •file.List "."
n←(".bqn"≡¯4⊸↑)¨⊸/¨(<•file.At¨•file.List)¨ d
err←d{(""⊣⟨𝕨⟩•BQN•FChars)⎊(•CurrentError∘@)¨𝕩}¨n
•Show⍟(⟨⟩≢⊢)¨ (⟨⟩≢1⊸⊑)¨⊸/¨ n ⋈¨¨ err
