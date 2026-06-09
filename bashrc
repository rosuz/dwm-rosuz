[[ $- != *i* ]] && return

iatest=$(expr index "$-" i)

if [ -f /usr/bin/fastfetch ]; then
  fastfetch
fi

for f in "$HOME/.config/bash"/*; do
  if [ ! -d "$f" ]; then
    source "$f"
  fi
done

if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi
