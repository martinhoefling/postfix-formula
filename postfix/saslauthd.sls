include:
  - postfix

exim4:
  pkg.purged

sasl_without_exim:
  pkg.installed:
    - pkgs:
      - sasl2-bin
      - libsasl2-modules
    - require:
      - pkg: exim4

/etc/default/saslauthd:
  file.managed:
    - source: salt://postfix/files/saslauthd.default

saslauthd:
  service.running:
    - watch:
      - file: /etc/default/saslauthd

/etc/postfix/sasl/smtpd.conf:
  file.managed:
    - contents: |
        pwcheck_method: saslauthd
        mech_list: PLAIN LOGIN
        saslauthd_path: /var/run/saslauthd/mux
        autotransition:true

add_postfix_to_sasl:
  cmd.run:
    - name:  usermod -a -G sasl postfix
    - unless: getent group sasl | grep postfix
    - watch_in:
      - service: postfix
      - service: saslauthd
