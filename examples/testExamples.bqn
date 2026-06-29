# Run every example and show errors
•Out "Examples to be tested:"∾∾´' '∾¨d←('d'=•file.Type¨)⊸/ •file.List "."
d •file.At¨↩
n←(".bqn"≡¯4⊸↑)¨⊸/¨(<•file.At¨•file.List)¨ d
err←d{(""⊣⟨𝕨⟩•BQN•FChars)⎊(•CurrentError∘@)¨𝕩}¨n
•Show⍟(⟨⟩≢⊢)¨ (⟨⟩≢1⊸⊑)¨⊸/¨ n ⋈¨¨ err
