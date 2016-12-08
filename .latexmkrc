# .latexmkrc file example
# http://tex.stackexchange.com/questions/123183

# Could also use "(setq auctex-latexmk-inherit-TeX-PDF-mode t)" in the
# Emacs configuration (Didn't test).
$pdf_mode = 1;

# Live update on save
$preview_continuous_mode = 1;

# Latexmk writes all the files to the directory, but AucTex's "C-c C-c
# Clean" doesn't clean it. Also can't use a hidden directory like
# '.latexmk', because makeindex treats it like an absolute path? Which
# is not writable for security reasons.
#
# $pdflatex="pdflatex -interaction=nonstopmode %O %S";
# $out_dir = '/latexmk_output';

$pdflatex = "pdflatex --shell-escape %O %S";
$pdf_previewer = "start evince %O %S";
