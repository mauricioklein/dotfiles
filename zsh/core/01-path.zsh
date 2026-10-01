#--------------------------------------------------------------#
##          PATH Deduplication                               ##
#--------------------------------------------------------------#

# Deduplicate PATH entries (removes duplicates while preserving order)
typeset -U path PATH fpath FPATH
