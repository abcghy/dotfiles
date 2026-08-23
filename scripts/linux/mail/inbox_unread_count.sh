#! /bin/bash

# Unread messages live in two places:
#  - Inbox/cur: files without the Seen (S) maildir flag
#  - Inbox/new: freshly fetched mail (mbsync puts unseen mail here)
cur=$(find "$HOME/.mail/personal/Inbox/cur" -type f ! -name "*,*S*" | wc -l)
new=$(find "$HOME/.mail/personal/Inbox/new" -type f | wc -l)
echo $((cur + new))
