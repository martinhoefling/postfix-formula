postfix_openssl:
  pkg.installed:
    - name: openssl

{% for length in ['2048', '1024', '512'] %}
gendh_{{ length }}:
  cmd.run:
    - name: openssl gendh -out /etc/postfix/dh_{{ length }}.pem -2 {{ length }}
    - unless: ls /etc/postfix/dh_{{ length }}.pem
    - watch_in:
      - service: postfix

{% endfor%}
