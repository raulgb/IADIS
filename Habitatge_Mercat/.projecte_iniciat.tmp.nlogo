globals [
  propietaris
  cases
  cases-llogades
  cases-llogades-T
  cases-llogades-A
  cases-llogades-M
  cases-llogades-B
  desocupat-A
  desocupat-M
  desocupat-B
  any
  mes
  canvi-mes
  dia
  bolsa-mercado
]

turtles-own [
  current-messages ;; Lista de mensajes actuales
  next-messages    ;; Lista de mensajes para la siguiente iteración
  tipo             ;; Tipus, si es propietari o llogater
  propietari       ;; En cas de ser una casa s'indica qui es el propietari
  buida            ;; si es casa hem de saber si esta plena o buida
  llogada          ;; Ens diu si esta llogada
  preu-sou-fix         ;; Preu fix del lloguer sobre el que s'opera
  preu-sou         ;; Preu o sou depenent de si es la casa o el llogater
  sou-desitjat     ;; Sou que desitja que tingui el llogater
  sou-pref         ;; Preferencia sou
  preu-lloguer     ;; Preu a pagar definitu
  llogater         ;; LLogater
  moviment         ;; Preu o sou depenent de si es la casa o el llogater
  inici-visites    ;; inici visites
  cases-visitades  ;; Cases ja visitades
  objectiu         ;; Te casa a la que vol visitar
  casa-objectiu    ;; Casa objectiu
  rebaixes         ;; Numero d'intents de rebaixes o rebaixes fetes
  classe           ;; Alta(A), "media"(M), baja(B), turista (T)
  multiplicador    ;; Depenent de la classe ara farem per llogater-casa: A-> (3-2.5),M->(2-1.5),B->(1-0.5)
  mesos-contracte  ;; Definim el numero de mesos de contracte
  mesos-revisar-pis;; Mesos que queden per tornar a revisar cases
  desocupat        ;; Si t'has quedat sense feina
  contracte-feina  ;; Temporal o fix - [ 0=SENSE; 1=FIX; 2=TEMPORAL]
  contracte-pref   ;; Preferencia sobre el contracte de feina
  diners           ;; Se va acumulando el dinero o perdiendo dependiendo
  pagament-avancat ;; Mesos que s'han de pagar per avançat, entre 3-6 mesos ho definirem
  tot-correcte     ;; Tenim totes les dades i pot pagar els mesos d'avançat
  puntuacio-client ;; Puntuacio en una negoaciacio
]

to setup
  clear-all
  reset-ticks
  ;; Iniciem els propietaris i els posem a la llista de propietaris - 5 propietaris ostenten totes les cases
  set propietaris []
  set bolsa-mercado 0
  set cases-llogades 0
  set cases-llogades-T 0
  set cases-llogades-A 0
  set cases-llogades-M 0
  set cases-llogades-B 0
  set dia 1
  set mes 1
  set canvi-mes 0
  set any 0

  ;;Dividim el territori en 3 classes
  ask patches [
    ifelse pxcor >= 0  and pycor > 0[
      set pcolor brown
    ][
      ifelse pxcor >= 0 and pycor <= 0[
        set pcolor blue
      ] [
        set pcolor green
      ]
    ]
  ]

  create-turtles 5 [
    set shape "box"
    set next-messages [] ;; Inicializamos las listas de mensajes recibidos
    setxy random-xcor random-ycor
    set tipo "P"
    if color = brown or color = blue or color = green [
      set color white
    ]

    set propietaris lput self propietaris
    set diners 0
    ;; Definim preferencies i obligacionsdels propietaris
    ;;Preferencies
    set contracte-feina (random 2)  + 1     ;; Tipus de contracte que prefereix FIX si es 1 i no li importa si es 2, sempre
                                            ;; Ha de tenir contracte per ser acceptat
    set contracte-pref (random 5) / 5       ;; Balanceig de la preferencia per cada propietari diferent 20,40,60,80
    set sou-desitjat (random 2500) + 500    ;; Defineix un sou entre 500 i 3000, que es el maxim
    set sou-pref 1 - contracte-pref         ;; Perque nomes tindrem dos preferencies definides
    ;;Obligacoins
    set pagament-avancat 3 + random 3
  ]

  ;; Iniciem els llogaters per classes

  ;; A Espanya 75% de contractes fixes la resta temporal, font Eurostat
  ;; Les dades d'idescat diuen que entre 16-64 anys el 80% de la poblacio treblla
  ;; el 20% no, d'aqui la modelitzacio
  ;; Per als de classe A posarem un 5% de desocupacio, nomes 2
  let contador-desocupats 0
  let contador-contracte 0
  set desocupat-A 0
  create-turtles 25 [
    set shape "person"
    set next-messages [] ;; Inicializamos las listas de mensajes recibidos
    setxy random-xcor random-ycor
    set tipo "L"
    set preu-sou-fix 500 + random 500
    set moviment true
    set inici-visites false
    set objectiu false
    set cases-visitades []
    set rebaixes 0
    set mesos-revisar-pis 24
    set classe "A"
    set multiplicador 3
    ifelse contador-desocupats < (25 * 0.05 ) [
      set desocupat true
      set contracte-feina 0
      set contador-desocupats contador-desocupats + 1
    ][

      ifelse contador-contracte < (50 * 0.75 ) [
        set contracte-feina 1
        set contador-contracte contador-contracte + 1
      ][
        set contracte-feina 2
      ]
      set desocupat false
    ]
    ifelse desocupat [
      set desocupat-A desocupat-A + 1
      set preu-sou 0
    ][
      ;; Multipliquem per 3 perque son classe alta
      set preu-sou preu-sou-fix * 3
    ]
    set diners 0
  ]
  ;; El 25% desocupats serien 13 aprox.
  set contador-desocupats 0
  set contador-contracte 0
  set desocupat-M 0
  create-turtles 50 [
    set shape "person"
    set next-messages [] ;; Inicializamos las listas de mensajes recibidos
    setxy random-xcor random-ycor
    set tipo "L"
    set preu-sou-fix 500 + random 500
    set moviment true
    set inici-visites false
    set objectiu false
    set cases-visitades []
    set rebaixes 0
    set mesos-revisar-pis 24
    set classe "M"
    set multiplicador 2
    ifelse contador-desocupats < (50 * 0.25 ) [
      set desocupat true
      set contracte-feina 0
      set contador-desocupats contador-desocupats + 1
    ][

      ifelse contador-contracte < (50 * 0.75 ) [
        set contracte-feina 1
        set contador-contracte contador-contracte + 1
      ][
        set contracte-feina 2
      ]
      set desocupat false
    ]
    ifelse desocupat [
      set desocupat-M desocupat-M + 1
      set preu-sou 0
    ][
      ;; Multipliquem per 2 perque son classe "media"
      set preu-sou preu-sou-fix * 2
    ]
    set diners 0
  ]

  ;; El 50% desocupats serien 13 aprox.
  set contador-desocupats 0
  set contador-contracte 0
  set desocupat-B 0
  create-turtles 25 [
    set shape "person"
    set next-messages [] ;; Inicializamos las listas de mensajes recibidos
    setxy random-xcor random-ycor
    set tipo "L"
    set preu-sou-fix 500 + random 500
    set moviment true
    set inici-visites false
    set objectiu false
    set cases-visitades []
    set rebaixes 0
    set mesos-revisar-pis 24
    set classe "B"
    set multiplicador 1
    ifelse contador-desocupats < (25 * 0.5 ) [
      set desocupat true
      set contracte-feina 0
      set contador-desocupats contador-desocupats + 1
    ][

    ifelse contador-contracte < (25 * 0.75 ) [
      set contracte-feina 1
      set contador-contracte contador-contracte + 1
    ][
      set contracte-feina 2
    ]
      set desocupat false
    ]

    ifelse desocupat [
      set desocupat-B desocupat-B + 1
      set preu-sou 0
    ][
      ;;El no es multiplica perque son els que menys cobren
      set preu-sou preu-sou-fix
    ]
    set diners 0
  ]

;; Iniciem els llogaters - turistes 25% dels que busquen lloguer
  create-turtles 25 [
    set shape "person"
    set next-messages [] ;; Inicializamos las listas de mensajes recibidos
    setxy random-xcor random-ycor
    set tipo "L"
    set preu-sou-fix 500 + random 500
    set moviment true
    set inici-visites false
    set objectiu false
    set cases-visitades []
    set rebaixes 0
    set mesos-revisar-pis 24
    set classe "T"
    set multiplicador 3
    ;; Multipliquem per 3 perque son classe alta
    set preu-sou preu-sou-fix * 3
    set diners 0
  ]

  ;;Iniciem les cases que tenen uns propietaris i les dividim per classes
  set cases []
  create-turtles 25 [
    set shape "house"
    set color white
    set next-messages [] ;; Inicializamos las listas de mensajes recibidos
    setxy random-xcor random-ycor
    if xcor < 0 [
      set xcor xcor * -1
    ]
    if ycor > 0 [
      set ycor ycor * -1
    ]
    set tipo "C"
    set propietari item (random 5) propietaris    ;; random 5 pels 5 propietaris
    set cases lput self cases
    set buida true
    set llogater nobody
    set llogada false
    ;; Preu en funcio de la classe de casa, Alta
    set preu-sou-fix (500 + random 500) * 2.5
    set preu-sou preu-sou-fix
    set classe "A"
    set tot-correcte false
  ]
    create-turtles 50 [
    set shape "house"
    set color white
    set next-messages [] ;; Inicializamos las listas de mensajes recibidos
    setxy random-xcor random-ycor

    if xcor >= 0  and ycor > 0[
      set xcor xcor * -1
      set ycor ycor * -1
    ]
    if xcor >= 0  and ycor <= 0[
      set xcor xcor * -1
      set ycor ycor * -1
    ]
    set tipo "C"
    set propietari item (random 5) propietaris    ;; random 5 pels 5 propietaris
    set cases lput self cases
    set buida true
    set llogater nobody
    set llogada false
    ;; Preu en funcio de la classe de casa, Mitjana
    set preu-sou-fix (500 + random 500) * 1.5
    set preu-sou preu-sou-fix
    set classe "M"
    set tot-correcte false
  ]
    create-turtles 25 [
    set shape "house"
    set color white
    set next-messages [] ;; Inicializamos las listas de mensajes recibidos
    setxy random-xcor random-ycor
    if xcor < 0 [
      set xcor xcor * -1
    ]
    if ycor < 0 [
      set ycor ycor * -1
    ]

    set tipo "C"
    set propietari item (random 5) propietaris    ;; random 5 pels 5 propietaris
    set cases lput self cases
    set buida true
    set llogater nobody
    set llogada false
    ;; Preu en funcio de la classe de casa, Baixa
    set preu-sou-fix (500 + random 500) * 0.5
    ;; Com es una casa de classe baixa
    set preu-sou preu-sou-fix
    set classe "B"
    set tot-correcte false
  ]
end

to go
  augmentem-dia            ;; Augmentem el dia en que ens trobem
  move-llogaters           ; Mou els llogaters
  swap-messages            ;; Activamos los mensajes mandados en la iteración anterior
  process-messages         ;; Procesamos los mensajes
  ;; move? do something?   ;; Actuamos
  send-messages            ;; Mandamos mensajes nuevos
  tick
end

;; Per cada passa augmenta un dia
to augmentem-dia
  set dia dia + 1
  set canvi-mes 0
  if dia > 30 [
    set mes mes + 1
    set canvi-mes 1
    set dia 1
    if mes > 12 [
      set any any + 1
      set mes 1
    ]
  ]
end

to move-llogaters
  ask turtles [
    if tipo = "L" [
      ;; Revisem els pisos que ja haviem mirat fa temps
      if canvi-mes = 1[
        set diners (diners + preu-sou)
        ;; print (word self diners)
        set mesos-revisar-pis mesos-revisar-pis - 1
        if mesos-revisar-pis = 0 and moviment[
          set mesos-revisar-pis 24
          borrar-llista
        ]
        ;; Definimos la posibilidad de que encuentre trabajo como un 10% i de que los despidan/fin-contrato tambien
        ;; Pels turistes no
        if classe != "T"[
          let canvi-treball random 100
          if canvi-treball < 10 [
            ;; Si esta a l'atur el contracten, si no el despedeixen
            ifelse desocupat [
              set desocupat false
              set preu-sou preu-sou-fix * multiplicador
              ;; La majoria dels nous contractes son temporals aqui ho definim com el 50% dels nous treballs
              let tipus-contracte random 2
              ifelse tipus-contracte = 0 [
                set contracte-feina 1
              ][
                set contracte-feina 2
              ]
            ] [
              ;; Si te contracte fix no el despedeix
              if contracte-feina = 2 [
                set desocupat true
                set preu-sou 0
              ]
            ]

            ;; Si canvian de trabajo augmentamos o no los monitores
            if classe = "A" and contracte-feina != 1[
              ifelse desocupat [
                set desocupat-A desocupat-A + 1
              ][
                set desocupat-A desocupat-A - 1
              ]
            ]

            if classe = "M" and contracte-feina != 1[
              ifelse desocupat [
                set desocupat-M desocupat-M + 1
              ][
                set desocupat-M desocupat-M - 1
              ]
            ]


            if classe = "B" and contracte-feina != 1[
              ifelse desocupat [
                set desocupat-B desocupat-B + 1
              ][
                set desocupat-B desocupat-B - 1
              ]
            ]
          ]
      ]
      ]
      ;; Fem una pasa
      if moviment [
       fd 1]

    ]
    if tipo = "C" [
      ifelse llogater = nobody [
        let percentatge-llogades (cases-llogades) / (length cases)
         if ( percentatge-llogades * 100 ) > 25 [
          set preu-sou preu-sou-fix + preu-sou-fix * 0.05 * ( 1 / ( 1 - percentatge-llogades ) )
        ]
      ] [
        ;; En cas de que estigui llogat anem reduint els mesos que li queden de contracte
        if canvi-mes = 1 [
          set mesos-contracte mesos-contracte - 1
          ;;Comprovem si pot assumir pagar el mes en cas contrari el fem fora
          let preu-temp preu-lloguer
          let pot-assumir-preu false
          ask llogater[
            if diners > preu-temp [
              ;;Li treiem els diners que li costa pagar el pis i definim que ho ha pogut pagar
              set diners diners - preu-temp
              set pot-assumir-preu true
            ]
          ]
          ifelse pot-assumir-preu [
            ;; Sumem els diners al propietari i a la bolsa del mercat
            ask propietari [
              set diners diners - 10  + (preu-temp * 0.99)
              set bolsa-mercado bolsa-mercado + 10  + (preu-temp * 0.01)
            ]
          ] [
            alliberar-llogater llogater
            alliberar-casa
          ]
          ;; Si se li acaba el contracte
          if mesos-contracte = 0 and pot-assumir-preu[
            let percentatge-llogades (cases-llogades) / (length cases)
            if ( percentatge-llogades * 100 ) > 25 [
              set preu-sou preu-sou-fix + preu-sou-fix * 0.05 * ( 1 / ( 1 - percentatge-llogades ) )
            ]
            ;;Comprovem si pot assumir el nou preu en funcio del mercat, en cas contrari el fem fora
            set preu-temp preu-sou
            set pot-assumir-preu false
            ask llogater[
              if preu-sou > preu-temp [
                ;;Li treiem els diners que li costa pagar el pis i definim que ho ha pogut pagar
                set pot-assumir-preu true
              ]
            ]
            ifelse pot-assumir-preu [
              set mesos-contracte 12
            ] [
              alliberar-llogater llogater
              alliberar-casa
            ]
          ]
        ]
      ]
    ]
  ]
end

to swap-messages
  ask turtles [
    set current-messages next-messages
    set next-messages []
  ]
end

to process-messages
  ask turtles [
    foreach current-messages [ ?1 ->
      process-message (item 0 ?1) (item 1 ?1) (item 2 ?1);; Cada mensaje es una lista [emisor tipo mensaje]
    ]
  ]
end

to send-messages
  ;; Solo como ejemplo, aquí tenemos un 10% de posibilidades de mandar oferta a algún otro agente
;  ask turtles [
;    let dice random 100
;    if dice < 10 and dice != who [
;      send-message (turtle dice) "oferta" ticks
;    ]
;  ]

  ask turtles [
    if tipo = "L" [
      let xcor-temp xcor
      let ycor-temp ycor
      let llogater-temp self
      let cases-plena false
      let inici-visites-temp inici-visites
      let cases-visitades-temp cases-visitades
      let objectiu-temp objectiu
      let casa-objectiu-temp casa-objectiu
      let classe-llogater classe
      ;; Comprovem si passen aprop d'una casa
      set cases shuffle cases
     (foreach cases
        [ [una-casa] -> ask una-casa [
        ;; Si es de classe alta no voldra comprar de classe baixa,
        ;; nomes esta disposat a comprar de classe mitja o alta
        ;; Al turista li es igual i als altres tambe
        if classe-llogater != "A" or classe != "B" [
            ;;Primero comprueba que no la haya visitado
            let visitada false
            ifelse inici-visites-temp [
              foreach cases-visitades-temp [casa-visitada ->
                if casa-visitada = una-casa [
                  set visitada true
                ]
              ]
            ] [
              ;; Inicializa la lista de casas visitadas
              set inici-visites-temp true
            ]

            let some_operation (((xcor - xcor-temp) * (xcor - xcor-temp) + (ycor - ycor-temp) * (ycor - ycor-temp) ) ^ (1 / 2))
            let xcor-temp2 xcor
            let ycor-temp2 ycor
            ;; Comprueba distancia, que este vacia la casa, que no haya escogido otra casa cercana ya(casa-plena), que no haya sido visitada, y que sea la casa que quiere visitar
            if some_operation < 1 and buida and cases-plena = false and not visitada and casa-objectiu-temp = self[
              send-message (llogater-temp) "oferta" ticks
              set cases-plena true
              set buida false
              ;; print (word self "esta a aprop de " llogater-temp)
            ]

            ;; En el cas que ja estigui ple l'objectiu segueix endavant
            if some_operation < 1 and not buida and cases-plena = false and not visitada and casa-objectiu-temp = self[
              ask llogater-temp [
                set objectiu objectiu-temp
                set heading towardsxy xcor-temp2 ycor-temp2
                if llogater != nobody [
                  set cases-visitades lput una-casa cases-visitades
                ]
                set objectiu-temp false
                set objectiu objectiu-temp
                set casa-objectiu-temp nobody
                set casa-objectiu casa-objectiu-temp
            ] ]

            ;;En el cas que no tingui cap aprop defineix un objectiu a distancia menor que 20
            if some_operation > 1 and some_operation < 20 and buida and cases-plena = false and not visitada and not objectiu-temp [
              set objectiu-temp true

              set casa-objectiu-temp self
              ask llogater-temp [
                set objectiu objectiu-temp
                set heading towardsxy xcor-temp2 ycor-temp2
                set casa-objectiu casa-objectiu-temp
              ]
            ]
          ]
      ]])
      set inici-visites inici-visites-temp
      if cases-plena [set moviment false]
    ]

  ]
end

;; Ejemplo de estructura para procesar mensajes de diferente tipo
to process-message [sender kind message]
  ;; PER LLOGATERS
  if kind = "oferta" and tipo = "L" [
    process-pregunta-buida-message sender message
  ]

  if kind = "preu" and tipo = "L" [
   comprova-preu sender message
  ]

  if kind = "pagament-avancat" and tipo = "L" [
    send-message sender "pagar-avancat" diners

  ]

  if kind = "demanda-contracte" and tipo = "L" [
    send-message sender "contracte-llogater" contracte-feina

  ]

  if kind = "demanda-sou" and tipo = "L" [
    send-message sender "sou-llogater" preu-sou

  ]

  if kind = "fin-negociacio" and tipo = "L" [
    alliberar-llogater-reservant self
  ]

  ;; PER CASES
  if kind = "buida" and tipo = "C"
    [ofereix-preu sender]
  ;; Comprova si tot correcte
  ifelse kind = "llogar" and tipo = "C" and tot-correcte [
    activa-lloguer sender
  ] [
    if  kind = "llogar" and tipo = "C" and not tot-correcte [
      demanda-diners sender
    ]
  ]


  if kind = "contracte-llogater" and tipo = "C" [
      comprova-contracte sender message
  ]


  if kind = "sou-llogater" and tipo = "C" [
      comprova-sou sender message
  ]

  if kind = "pagar-avancat" and tipo = "C" [
      comprovem-si-tot-correcte sender message
  ]

  if kind = "rebaixa" and tipo = "C" [
    ofereix-preu-rebaixa sender message
  ]
; if kind = "Pong" [
;   process-pong-message sender message
; ]
end

;; Ofereix el preu de la casa al llogater
to ofereix-preu [sender]
  ask self[
      send-message sender "preu" preu-sou
  ]
end



;; Iniciem la demanda de certes caracteristiques del comprador per decidir si el volem o volem un altre
to demanda-diners [sender]
  send-message sender "pagament-avancat" "NoMessage"
end

;; Comprovem si amb els diners que diu que te pot pagar els 3-6 mesos per adelantat,
;; Mes un del mes actual, si es aixi li cobrarem 3-6 mesos quan es firmi el contracte
to comprovem-si-tot-correcte [sender diners-temp]
  ask self[
    let pagament-avancat-temp 0
    ask propietari [
      set pagament-avancat-temp pagament-avancat
    ]
    ;; Definim quans diners ha de disposar per poder entrar a la casa a part de tenir un sou X
    ifelse diners-temp > (preu-lloguer * (pagament-avancat + 1))[
      send-message sender "demanda-contracte" "NoMessage"
    ] [
        send-message sender "fin-negociacio" "NoMessage"
        set buida true
    ]
  ]
end

to comprova-contracte [sender contracte]
  ask self [
    ;; Iniciem la puntuacio del client a 0
    set puntuacio-client 0
    let puntuacio-client-temp puntuacio-client
    ask propietari[
      ;;Depenent del contracte modifiquem la puntuacio
      ifelse contracte = 1 and contracte-feina = 1[
        set puntuacio-client-temp contracte-pref
      ][
        ifelse contracte = 2 and contracte-feina = 1[
          set puntuacio-client-temp contracte-pref * 0.5
        ][
          if contracte-feina = 1[
            set puntuacio-client-temp contracte-pref
          ]
        ]
      ]
    ]
    set puntuacio-client puntuacio-client-temp
    ;;activa-lloguer sender
    send-message sender "demanda-sou" "NoMessage"
  ]

end

to comprova-sou [sender sou]
  ask self [

    let puntuacio-client-temp puntuacio-client
    ask propietari [
    ;;Depenent del sou modifiquem la puntuacio
      ifelse sou-desitjat >= sou [
      set puntuacio-client-temp puntuacio-client-temp + ((sou / sou-desitjat) * sou-pref)
      ] [
        ;; En caso de que cobre mas que el sueldo deseado por el propietario
      set puntuacio-client-temp puntuacio-client-temp + (sou-pref)
      ]
    ]
    set puntuacio-client puntuacio-client-temp
    activa-lloguer sender
    print (word self " puntua a " sender " aixi: " puntuacio-client)
  ]

end

;; Ofereix el preu de la casa al llogater amb una rebaixa
to ofereix-preu-rebaixa [sender message]
  ask self[
      send-message sender "preu" preu-sou * 0.85
  ]
end

;; Comprova el preu i si es inferior al sou la lloga
to comprova-preu [sender preu]
  ask self[
    ;; print (word self preu " cobra " preu-sou)
    ifelse preu < preu-sou
    [
     llogar-casa sender "Vull llogar"
      ask sender[
        set preu-lloguer preu
      ]
      set rebaixes 0
    ]
    [
      ifelse rebaixes < 3 [
        set rebaixes rebaixes + 1
        demanda-rebaixa sender preu-sou
      ]
     [
        set cases-visitades lput sender cases-visitades
        ;; print (word self cases-visitades)
        set moviment true
        set objectiu false
        set casa-objectiu nobody
        set rebaixes 0
        ask sender[
          set buida true
        ]
    ]
    ]
  ]
end

;; Quan un llogater s'enva reestablim certs valors
to alliberar-casa
  ask self[
    let deposit (preu-lloguer * pagament-avancat)
    set diners diners - deposit
    ask llogater[
    set diners diners + deposit
      ifelse classe = "T" [
        set cases-llogades-T cases-llogades-T - 1
      ][
       ifelse classe = "A" [
          set cases-llogades-A cases-llogades-A - 1
        ][
          ifelse classe = "M" [
            set cases-llogades-M cases-llogades-M - 1
          ][
            set cases-llogades-B cases-llogades-B - 1
          ]
        ]
      ]
    ]
    set buida true
    set llogater nobody
    set llogada false
    set color white
    set cases-llogades cases-llogades - 1
  ]
end

;;

;; Alliberar llogater
;; Per alliberarlo quan esta intentant llogar
to alliberar-llogater-reservant [llogater-temp]
  ask llogater-temp[
    set moviment true
    set inici-visites false
    set objectiu false
    set casa-objectiu nobody
    set rebaixes 0
  ]
end

;; Per alliberarlo quan esta llogant
to alliberar-llogater [llogater-temp]
  ask llogater-temp[
    set moviment true
    set inici-visites false
    set objectiu false
    set cases-visitades []
    set rebaixes 0
    set mesos-revisar-pis 24
  ]
end
;; Lloga casa
to llogar-casa [sender message]
  send-message sender "llogar" message
end

;; Borra la llista de pisos visitats
to borrar-llista
  ask self [
    set cases-visitades []
  ]
end

;; Activa certs elements del lloguer
to activa-lloguer [sender]
  ask self[
    set mesos-contracte 12
    set buida false
    set color red
    set llogater sender
    set llogada true
    let preu-lloguer-temp preu-lloguer
    ;;Mesos a pagar per avancat
    let pagament-avancat-temp pagament-avancat
    ask llogater[
      set diners diners - (preu-lloguer-temp * pagament-avancat-temp)
      ifelse classe = "T" [
        set cases-llogades-T cases-llogades-T + 1
      ][
       ifelse classe = "A" [
          set cases-llogades-A cases-llogades-A + 1
        ][
          ifelse classe = "M" [
            set cases-llogades-M cases-llogades-M + 1
          ][
            set cases-llogades-B cases-llogades-B + 1
          ]
        ]
      ]
    ]
    ;; Como esto no es la compra de ningun producto sino un deposito no ponemos la comission al mercado
    set diners diners + (preu-lloguer-temp * pagament-avancat-temp)
    set cases-llogades cases-llogades + 1
  ]
end

;;Demanda de rebaixa, li enviem el sou
to demanda-rebaixa [sender message]
  send-message sender "rebaixa" message

end

  ;; A los ofertas responem preguntant si esta buida
to process-pregunta-buida-message [sender message]
  send-message sender "buida" message
  ;;; print (word self " oferta? " message " from " sender tipo)
end

;to process-pong-message [sender message]
;  ;; En los buidas solo mostramos que lo hemos recibido
;  ;; print (word self " PONG! " message " from " sender tipo)
;end

to send-message [recipient kind message]
  ;; Añadimos el mensaje a la cola de mensajes del agente receptor
  ;; (se añade a next-messages para que el receptor no lo vea hasta la siguiente iteración)
  ask recipient [
    set next-messages lput (list myself kind message) next-messages
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
30
42
96
75
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
108
46
171
79
Run
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
35
93
137
138
cases-lloguer
cases-llogades
17
1
11

MONITOR
64
197
188
242
Turistes-ocupats
cases-llogades-T
17
1
11

MONITOR
46
267
171
312
ClasseA-Ocupats
cases-llogades-A
17
1
11

MONITOR
44
322
171
367
ClasseM-Ocupats
cases-llogades-M
17
1
11

MONITOR
44
377
170
422
ClasseB-Ocupats
cases-llogades-B
17
1
11

MONITOR
702
163
849
208
desocupats-ClasseA
desocupat-A
17
1
11

MONITOR
708
218
849
263
desocupat-ClasseM
desocupat-M
17
1
11

MONITOR
709
280
849
325
desocupat-ClassaB
desocupat-B
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
