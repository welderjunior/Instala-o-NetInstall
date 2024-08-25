# OBS: 
# 1 - A regra de drop geral já vem desabilitada no script por padrão. Para não perde acesso ao Mikrotik, antes de
# habilitar a regra, adicione os prefixos na lista REDE-SUPORTE que terão acesso ao disposito;
# 2 - Se tiver habilitado o DROP GERAL antes de colocar os prefixos permitidos, faça um Toc Toc(Port Knocking) nas portas: 15056, 8023 e 34752;
# 3 - Caso utilize OSPF ative a regra para aceitar conexões OSPF;
# 4 - Para evitar problemas em subir o OSPF em roteadores que façam o CGNAT, habilite a regra com o comentário "OSPF FORA DO NAT" na tabela raw.


/ip firewall filter
add action=accept chain=input comment=\
    "ACEITA NO MAXIMO 50 PACOTES DE ICMP POR SEGUNDO" dst-address-type="" \
    limit=50,5:packet protocol=icmp
add action=drop chain=input comment="DROPA PING FLOOD" protocol=icmp
add action=accept chain=input comment=\
    "ACEITA CONEXOES ESTABELECIDAS OU RELACIONADAS" connection-state=\
    established,related
add action=accept chain=input comment="ACEITA REDE DE SUPORTE" \
    src-address-list=REDE-SUPORTE
add action=accept chain=input comment="ACEITA DNS" dst-port=53 protocol=tcp
add action=accept chain=input comment="ACEITA DNS" dst-port=53 protocol=udp
add action=add-src-to-address-list address-list=PORTSCAN \
    address-list-timeout=7d chain=input comment=PORTSCAN dst-address-type="" \
    psd=21,3s,3,1
add action=add-src-to-address-list address-list=PORTSCAN address-list-timeout=7d \
    chain=input comment="DETECTA PORTSCARN" dst-port=20-25,3389,8291 protocol=tcp
add action=add-src-to-address-list address-list=PORT-KNOCKING-1 \
    address-list-timeout=3s chain=input comment="1 ETAPA PORT KNOCKING" \
    dst-port=15056 protocol=tcp
add action=add-src-to-address-list address-list=PORT-KNOCKING-2 \
    address-list-timeout=3s chain=input comment="2 ETAPA PORT KNOCKING" \
    dst-port=8023 protocol=tcp \
    src-address-list=PORT-KNOCKING-1
add action=add-src-to-address-list address-list=REDE-SUPORTE \
    address-list-timeout=3h chain=input comment="ETAPA FINAL PORT KNOCKING" \
    dst-port=34752 protocol=tcp \
    src-address-list=PORT-KNOCKING-2
add action=accept chain=input comment="ACEITA OSP" \
    protocol=ospf disabled=yes
add action=drop chain=input comment="DROP GERAL" disabled=yes
/ip firewall raw
add action=drop chain=prerouting comment="DROPA PORTSCAN" src-address-list=\
    PORTSCAN
add action=notrack chain=output comment="OSPF FORA DO NAT" protocol=ospf disabled=yes
