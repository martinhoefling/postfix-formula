{% from "postfix/map.jinja" import postfix with context %}

postfix:
  {% if postfix.packages is defined %}
  pkg.installed:
    - names:
  {% for name in postfix.packages %}
        - {{ name }}
  {% endfor %}
    - watch_in:
      - service: postfix
  {% endif %}
  service.running:
    - enable: True
    - require:
      - pkg: postfix
    - watch:
      - pkg: postfix

# manage /etc/aliases if data found in pillar
{% if 'aliases' in pillar.get('postfix', '') %}
/etc/aliases:
  file.managed:
    - source: salt://postfix/aliases
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: postfix

run-newaliases:
  cmd.wait:
    - name: newaliases
    - cwd: /
    - watch:
      - file: /etc/aliases
{% endif %}

{% for postmap in ['virtual', 'sasl_passwd', 'relaymap'] %}
# manage /etc/postfix/virtual if data found in pillar
{% if postmap in pillar.get('postfix', '') %}
/etc/postfix/{{ postmap }}:
  file.managed:
    - contents_pillar: postfix:{{ postmap }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: postfix

run-postmap-{{ postmap }}:
  cmd.wait:
    - name: /usr/sbin/postmap /etc/postfix/{{ postmap }}
    - cwd: /
    - watch:
      - file: /etc/postfix/{{ postmap }}
{% endif %}
{% endfor %}
