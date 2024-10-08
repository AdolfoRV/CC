#!/usr/bin/bash

trap "rm -rf /tmp/def.dicc" EXIT
ARCH=$(arch)
DEFINIR=./$1
chmod +x prof.ref-$ARCH

clean() {
  rm -rf /tmp/def.dicc
}

test() {
  DICC=$1
  LLAVE=$2
  VAL=$3
  EXTRA=$4
  if [ -f $DICC ] && [ -w $DICC ] ; then
    cp $DICC dicc-ref.txt
  fi
  echo "Ejecutando: $DEFINIR $DICC $LLAVE" '"'$VAL'"' $EXTRA
  if [ -f $DICC ] ; then
    cp $DICC dicc-bug.txt
  fi
  ( $DEFINIR $DICC $LLAVE "$VAL" $EXTRA > raw-std.txt ) >& err.txt
  RC=$?
  cat raw-std.txt | xargs > std.txt
  if [ -f $DICC ] && [ -w $DICC ] ; then
    mv $DICC dicc.bak
    mv dicc-ref.txt $DICC
  fi
  ( ./prof.ref-$ARCH $DICC $LLAVE "$VAL" $EXTRA > raw-std-ref.txt ) >& err-ref.txt
  REFRC=$?
  cat raw-std-ref.txt | xargs > std-ref.txt
  if [ -f $DICC ] && [ -w $DICC ] ; then
    mv $DICC dicc-ref.txt
    mv dicc.bak $DICC
  fi

  cmp err.txt err-ref.txt
  if [ $? -ne 0 ]
  then
    echo "*** Salida estandar de errores incorrecta ***"
    echo "Su solucion entrega en la salida estandar de errores:"
    echo "============================================================"
    cat err.txt
    echo "============================================================"
    echo "Debio ser:"
    echo "============================================================"
    cat err-ref.txt
    echo "============================================================"
    echo "Si la salida parece ser igual, instale xxdiff con:"
    echo "    sudo apt-get install xxdiff"
    echo "y luego compare los caracteres invisibles con:"
    echo "xxdiff err.txt err-ref.txt"
    echo "Para depurar lance ddd con: make ddd"
    echo "En la ventana de ddd, coloque un breakpoint con: b main"
    echo "Ejecute con: run dicc-bug.txt $LLAVE" '"'$VAL'"'
    echo "Ejecute paso a paso con el boton next"
#   clean
    exit 1
  fi
  cat err.txt

  cmp std.txt std-ref.txt
  if [ $? -ne 0 ]
  then
    echo "*** Salida estandar incorrecta ***"
    echo "Su solucion entrega en la salida estandar:"
    echo "============================================================"
    cat std.txt
    echo "============================================================"
    echo "Debio ser:"
    echo "============================================================"
    cat std-ref.txt
    echo "============================================================"
    echo "Si la salida parece ser igual, instale xxdiff con:"
    echo "    sudo apt-get install xxdiff"
    echo "y luego compare los caracteres invisibles con:"
    echo "xxdiff std.txt std-ref.txt"
    echo "Para depurar lance ddd con: make ddd"
    echo "En la ventana de ddd, coloque un breakpoint con: b main"
    echo "Ejecute con: run dicc-bug.txt $LLAVE" '"'$VAL'"'
    echo "Ejecute paso a paso con el boton next"
#   clean
    exit 1
  fi
  cat raw-std.txt

  if [ "$RC" == 0 ]
  then
    if [ "$REFRC" != 0 ]
    then
      echo "El codigo de retorno es incorrectamente 0.  Debio ser $REFRC"
#     clean
      exit 1
    fi
  fi
  if [ "$RC" != 0 ]
  then
    if [ "$REFRC" == 0 ]
    then
      echo "El codigo de retorno es incorrectamente $RC.  Debio ser 0"
#     clean
      exit 1
    fi
  fi
  if [ "$RC" != 0 ]
  then
    echo "Bien.  Se diagnostico correctamente el error."
  fi

  if [ -f $DICC ] && [ -w $DICC ] ; then
    diff $DICC dicc-ref.txt
    if [ $? -ne 0 ]
    then
      echo "*** El diccionario resultante es incorrecto ***"
      echo "Se uso el comando diff para mostrar las direrencias con el"
      echo "diccionario de referencia"
      echo "Para visualizar mejor la diferencias, instale xxdiff con:"
      echo "    sudo apt-get install xxdiff"
      echo "y luego compare los archivos con"
      echo "xxdiff $DICC dicc-ref.txt"
      echo "Para depurar lance ddd con: make ddd"
      echo "En la ventana de ddd, coloque un breakpoint con: b main"
      echo "Ejecute con: run dicc-bug.txt $LLAVE" '"'$VAL'"'
      echo "Ejecute paso a paso con el boton next"
#     clean
      exit 1
    fi
  fi
}

echo "-----------------------------------------------------------"
echo "Tests unitarios"
echo "Creando def.dicc como un diccionario vacio"
rm -f def.dicc
touch def.dicc
test def.dicc embarcacion "todo tipo de artilugio capaz de navegar en el agua"
test def.dicc casa "edificacion construida para ser habitada"
test def.dicc lluvia "precipitacion de particulas liquidas de agua"
test def.dicc alimento "sustancia ingerida por un ser vivo"
test def.dicc celular "aparato portatil de un sistema de telefonia celular"
test def.dicc canario "ave paseriforme de la familia de los fringilidos"
test def.dicc palacio "edificio utilizado como residencia de un magnate"
test def.dicc bolsillo "bolsa pequena"
test def.dicc correr "andar tan rapidamente que los pies quedan en el aire"
test def.dicc nadar "trasladarse en el agua, con los brazos y sin tocar el suelo"
test def.dicc posada "establecimiento economico de hospedaje para viajeros"
test def.dicc taladro "herramienta aguda o cortante con que se agujerea la madera"
test def.dicc perro "mamifero domestico con olfato muy fino, inteligente y leal"
test def.dicc techo "parte superior de un edificio que lo cubre y cierra"

echo "-----------------------------------------------------------"
echo "Test con llave existente"
test def.dicc alimento "sustancia ingerida por un ser vivo"
test def.dicc correr "andar tan rapidamente que los pies quedan en el aire"
test def.dicc nadar "trasladarse en el agua, con los brazos y sin tocar el suelo"
test def.dicc posada "establecimiento economico de hospedaje para viajeros"
test def.dicc taladro "herramienta aguda o cortante con que se agujerea la madera"
test def.dicc perro "mamifero domestico con olfato muy fino, inteligente y leal"
test def.dicc techo "parte superior de un edificio que lo cubre y cierra"


echo "-----------------------------------------------------------"
echo "Test con un diccionario inexistente"
test nodef.dicc bolsillo "bla bla"
echo "-----------------------------------------------------------"
echo "Test con diccionario sin permiso de escritura"
cp def.dicc /tmp/
chmod -w /tmp/def.dicc
test /tmp/def.dicc evangelio "bla bla"
rm -f /tmp/def.dicc

echo "-----------------------------------------------------------"
echo "Test de uso incorrecto de parametros"
test def.dicc def.dicc "bolsa pequena" error
test def.dicc

echo
echo "Felicitaciones: aprobo todos los tests"
