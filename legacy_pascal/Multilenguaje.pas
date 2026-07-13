unit Multilenguaje;

{$MODE Delphi}

{*******************************************************************************
Contiene el soporte multilenguaje de todos los formularios del proyecto Galatea
Proyecto: Galatea
Versión: 1.0
Autor: Benjamín Piña Altamirano
*******************************************************************************}

interface

type
  TLenguaje = (lEspanol, lEnglish);
  TMensajeIndice = 0..10000;

const
  {Mensajes generales}
  mlHola        = 0;
  mlSnTtl       = 1;
  mlNum         = 2;
  mlNombre      = 3;
  mlDefecto     = 4;
  mlPropiedades = 5;
  mlAgua        = 6;
  mlAzucar      = 7;
  mlGrasa       = 8;
  mlProteina    = 9;
  mlMovimiento  = 10;
  mlEnReposo    = 11;
  mlMacho       = 12;
  mlHembra      = 13;
  mlHuevo       = 14;
  mlInmaduro    = 15;
  mlCaracter    = 16;
  mlValor       = 17;
  mlDinamico    = 18;
  mlEmisor      = 19;
  mlReceptor    = 20;
  mlFntAgua     = 21;
  mlFntAzucar   = 22;
  mlFntGrasa    = 23;
  mlFntPrtn     = 24;
  mlSitOvipo    = 25;
  mlValores     = 26;
  mlVelocidad   = 27;
  mlNinguno     = 28;
  mlPrototipo   = 29;
  mlPrototipos  = 30;
  mlColor       = 40;
  mlY           = 41;
  mlO           = 42;
  mlAdulto      = 43;
  mlCrctrstcs   = 44;
  mlCombate     = 45;
  mlCortejo     = 46;
  mlMachos      = 47;
  mlHembras     = 48;
  mlDinamicos   = 49;
  mlNS          = 50;
  mlEO          = 51;
  mlNO          = 52;
  mlW           = 53;
  mlSO          = 54;
  mlUltInt      = 55;
  mlNumInt      = 56;
  mlUltVz       = 57;
  mlNumVcs      = 58;
  mlPqtEsprmtc  = 59;
  mlForrajeo    = 60;
  mlRprdccn     = 61;
  mlContendiente= 62;
  mlUltPer      = 63;
  mlNumPer      = 64;
  mlIndefinido  = 65;
  mlCiclos      = 66;
  mlGenetico    = 67;
  mlAmbiental   = 68;

  {Mensajes generales de error}

  mlErrNVld     = 500;
  mlErrSm100    = 501;
  mlErrArchvNE  = 502;
  mlErrMinPer   = 506;
  mlErrMaxPer   = 507;
  mlErrNeg      = 508;
  mlErrFracc    = 509;

  {Mensajes de Galatea}

  mlProyecto    = 1001;
  mlProyectos   = 1002;
  mlGrdProyNv   = 1003;
  mlGrdProyCr   = 1004;
  mlDrProyNe    = 1005;
  mlFechaInicio = 1006;
  mlFechaFin    = 1007;
  mlSegundos    = 1008;
  mlMinutos     = 1009;
  mlHoras       = 1010;
  mlDias        = 1011;
  mlHoraInicio  = 1012;
  mlHoraFin     = 1013;
  mlTiempoTotal = 1014;
  mlDuracCiclo  = 1015;
  mlArchSalida  = 1016;
  mlSalida      = 1017;
  mlTodosMuertos= 1018;
  mlPregDetener = 1019;
  mlDirSalNE    = 1020;

  {Mensajes de error de Galatea}

  mlErrFltEdEs  = 1500;
  mlErrFltEdSu  = 1501;
  mlErrFltEs    = 1502;
  mlErrFltEdAg  = 1503;
  mlErrFltEdEn  = 1504;
  mlErrExtNCGL  = 1505;
  mlFltArchEntrn= 1506;
  mlErrDirSalNC = 1507;
  mlErrFltAnlzdr= 1508;

  {Mensajes del Editor de Escenario}

  mlEdEsGl      = 2001;
  mlEscenario   = 2002;
  mlGrdEsNv     = 2003;
  mlGrdEsCr     = 2004;
  mlEscenarios  = 2005;
  mlDrEsNE      = 2006;
  mlSustActual  = 2007;
  mlSustMixto   = 2008;

  {Mensajes de error del Editor de Escenarios}

  //mlErrPrcntjZ  = 2500;
  mlErrFltJS    = 2501;
  mlErrExtNCEE  = 2502;

  {Mensajes del Editor de Sustratos}
  mlEdSustGl    = 3001;
  mlGuardSustNv = 3002;
  mlJgoSustrs   = 3003;
  mlGrdSustCr   = 3004;
  mlSustratos   = 3005;
  mlDrSustrNE   = 3006;
  mlSustrVc     = 3007;
  mlSgrElmSustr = 3008;
  mlSustrato    = 3009;

  {Mensajes de error del Editor de Sustratos}

  mlErrExtNCES  = 3500;

  {Mensajes del Editor de Entornos}

  mlEdEntGlt    = 4001;
  mlEntorno     = 4002;
  mlEntornos    = 4003;
  mlElmntActl   = 4004;
  mlGrdEntNv    = 4005;
  mlGrdEntCr    = 4006;
  mlDrEntNE     = 4007;
  mlNoElmntOvps = 4008;
  mlEditarPuesta= 4009;
  mlFltJgAgnts  = 4010;
  {mlEscAltMn    = 4008;
  mlEscAncMn    = 4009; }

  {Mensajes de error del Editor de Entornos}

  mlFltEscAsc   = 4500;
  mlFltAgntAsc  = 4501;
  mlErrExtNCEEN = 4502;
  mlNoSlccElmnt = 4503;
  mlNoCncdStrts = 4504;
  mlLcsPtrn     = 4505;
  mlLcsMtrn     = 4506;
  mlLcsExprsd   = 4507;
  mlNoElmntEdt  = 4508;
  mlTmnEscnrMnr = 4509;
  mlNmrPrttMnr  = 4510;
  mlNMrcCsllSust= 4511;
  mlSustNngnCdr = 4512;
  mlNvlMxHvs    = 4513;

  {Mensajes del Editor de Agentes}

  mlEdAgntGlt   = 5000;
  mlJgoAgnts    = 5001;
  mlGrdAgntNv   = 5002;
  mlGrdAgntCr   = 5003;
  mlDrAgntNE    = 5004;
  mlAgente      = 5005;
  mlAgentes     = 5006;
  mlVarianza    = 5007;
  mlDiscreto    = 5008;
  mlContinuo    = 5009;
  mlConducta    = 5010;
  mlCosto       = 5011;
  mlMinimo      = 5012;
  mlCritico     = 5013;
  mlOptimo      = 5014;
  mlInicial     = 5015;
  mlMaximo      = 5016;
  mlNutrimentos = 5017;
  mlRqrmnts     = 5018;
  mlCostos      = 5019;
  mlElmnrPrttp  = 5020;
  mlElmnrEstd   = 5021;
  mlBeber       = 5022;
  mlCmrGrasa    = 5023;
  mlCmrAzucar   = 5024;
  mlCmrProteina = 5025;
  mlTasaMutacion= 5026;
  mlRsltFrml    = 5027;
  mlOvipositar  = 5028;
  mlDblClcEdCl  = 5029;
  mlDblClcEdFr  = 5030;
  mlDesplegar   = 5031;
  mlEscalar     = 5032;
  mlRetirar     = 5033;
  mlIA          = 5034;
  mlIB          = 5035;
  mlCopular     = 5036;
  mlRechazar    = 5037;
  mlDominante   = 5038;
  mlRecesivo    = 5039;
  mlOperador    = 5040;
  mlFormula     = 5041;
  mlRangoMut    = 5042;
  mlEstadio     = 5043;
  mlEstadios    = 5044;
  mlPrttMachos  = 5045;
  mlPrttHembras = 5046;
  mlLociCont    = 5047;
  mlLociDisc    = 5048;
  mlCarCont     = 5049;
  mlCarDisc     = 5050;
  mlMaxHuevos   = 5051;
  mlMaxEsperma  = 5052;
  mlCostoUnidad = 5053;
  mlNtrmntUndds = 5054;
  mlNmrPETC     = 5055;
  mlMaxPEAH     = 5056;
  mlTasaConsmPE = 5057;
  mlFrccHFC     = 5058;
  mlPrbbPtrnd   = 5059;
  mlHvsOvpstd   = 5060;
  mlPrddPE      = 5061;
  mlPrddHv      = 5062;
  mlCambrEst    = 5063;
  mlYOReqrmnts  = 5064;
  mlLongevidad  = 5065;
  mlAsgncnSx    = 5066;
  mlRfrctr      = 5067;
  mlEstrtgCombt = 5068;
  mlEstrtgCortj = 5069;
  mlCrtrsAsgnc  = 5070;
  mlAsgncnJrrq  = 5071;
  mlMatrizInt   = 5072;
  mlMatrizAtr   = 5073;
  mlMatrizMem   = 5074;
  mlMatrizMemCon= 5075;
  mlEdFormls    = 5076;
  mlPeleaGanada = 5077;
  mlPeleaPerdida= 5078;
  mlRefractario = 5079;
  mlMemoria     = 5080;
  mlMetabolismo = 5081;
  mlFisiologia  = 5082;
  mlPrdccnGmts  = 5083;
  mlPrdEnrgtc   = 5084;
  mlMorfologia  = 5085;
  mlLlnrCld     = 5086;
  mlMorir       = 5087;
  mlAtractividad= 5088;
  mlRdPrcpcn    = 5089;
  mlIniTdsClds  = 5090;
  mlCondicion   = 5091;
  mlTndncsMvmnt = 5092;
  mlAceptacion  = 5093;
  mlDegrEsperma = 5094;
  mlDinGam      = 5095;

  {Mensajes de error del Editor de Agentes}

  mlErrExtNCEA  = 5500;
  mlErrMtcnMnr1 = 5501;
  mlErrFltPlnt  = 5502;

  {Mensajes del Analizador de Salidas}

  mlAnlzdrSlds  = 6000;

  {Mensajes de error del Analizador de Salidas}

var
  Lenguaje: TLenguaje = lEnglish;

function ML(Indice: TMensajeIndice): string;

implementation

function MLEspanol(Indice: TMensajeIndice): string;
begin
  case Indice of
    {Mensajes generales}
    mlHola        : Result := 'Hola';
    mlSnTtl       : Result := 'Sin título';
    mlNum         : Result := 'Número';
    mlNombre      : Result := 'Nombre';
    mlDefecto     : Result := 'Por defecto';
    mlPropiedades : Result := 'Propiedades';
    mlAgua        : Result := 'Agua';
    mlAzucar      : Result := 'Carbohidratos';
    mlGrasa       : Result := 'Lípidos';
    mlProteina    : Result := 'Proteina';
    mlMovimiento  : Result := 'Movimiento';
    mlEnReposo    : Result := 'En reposo';
    mlMacho       : Result := 'Macho';
    mlHembra      : Result := 'Hembra';
    mlHuevo       : Result := 'Huevo';
    mlInmaduro    : Result := 'Inmaduro';
    mlCaracter    : Result := 'Caracter';
    mlValor       : Result := 'Valor';
    mlDinamico    : Result := 'E. Dinámico';
    mlEmisor      : Result := 'Emisor';
    mlReceptor    : Result := 'Receptor';
    mlFntAgua     : Result := 'Fuente Agua';
    mlFntAzucar   : Result := 'Fuente Carbohidratos';
    mlFntGrasa    : Result := 'Fuente Lípidos';
    mlFntPrtn     : Result := 'Fuente Proteina';
    mlSitOvipo    : Result := 'Sitio Oviposición';
    mlValores     : Result := 'Valores';
    mlVelocidad   : Result := 'Velocidad';
    mlNinguno     : Result := 'Ninguno';
    mlPrototipo   : Result := 'Prototipo';
    mlPrototipos  : Result := 'Prototipos';
    mlColor       : Result := 'Color';
    mlY           : Result := 'y';
    mlO           : Result := 'o';
    mlAdulto      : Result := 'Adulto';
    mlCrctrstcs   : Result := 'Características';
    mlCombate     : Result := 'Combate';
    mlCortejo     : Result := 'Cortejo';
    mlMachos      : Result := 'Machos';
    mlHembras     : Result := 'Hembras';
    mlDinamicos   : Result := 'Elementos Dinamicos';
    mlNS          : Result := 'N-S';
    mlEO          : Result := 'E-O';
    mlNO          : Result := 'NO';
    mlW           : Result := 'O';
    mlSO          : Result := 'SO';
    mlUltInt      : Result := 'Última interacción ';
    mlNumInt      : Result := 'Número interacciones ';
    mlUltVz       : Result := 'Última vez ';
    mlNumVcs      : Result := 'Número de veces ';
    mlPqtEsprmtc  : Result := 'Paquete espermático';
    mlForrajeo    : Result := 'Forrajeo';
    mlRprdccn     : Result := 'Reproducción';
    mlContendiente: Result := 'Contendiente';
    mlUltPer      : Result := 'Última percepción ';
    mlNumPer      : Result := 'Número percepciones ';
    mlIndefinido  : Result := 'Indefinido';
    mlCiclos      : Result := 'Ciclos';
    mlGenetico    : Result := 'Genetico';
    mlAmbiental   : Result := 'Ambiental';
    {Mensajes generales de error}
    mlErrNVld     : Result := 'El valor especificado es incorrecto.';
    mlErrSm100    : Result := 'La suma de los porcentajes debe ser igual a '
                      + '100.';
    mlErrArchvNE  : Result := 'No existe el archivo';
    mlErrMinPer   : Result := 'El valor mínimo permitido es ';
    mlErrMaxPer   : Result := 'El valor máximo permitido es ';
    mlErrNeg      : Result := 'El valor debe ser positivo.';
    mlErrFracc    : Result := 'El valor debe estar entre 0 y 1';
    {Mensajes de Galatea}
    mlProyecto    : Result := 'Proyecto';
    mlProyectos   : Result := 'Proyectos';
    mlGrdProyNv   : Result := '¿Desea guardar los cambios en el proyecto '
                      + 'actual antes de crear uno nuevo';
    mlGrdProyCr   : Result := '¿Desea guardar los cambios en el proyecto actual '
                      + 'antes de cerrarlo';
    mlDrProyNe    : Result := 'El directorio de proyectos no existe, ¿desea '
                      + 'crearlo';
    mlFechaInicio : Result := 'Fecha inicio';
    mlFechaFin    : Result := 'Fecha fin';
    mlSegundos    : Result := 'Segundos';
    mlMinutos     : Result := 'Minutos';
    mlHoras       : Result := 'Horas';
    mlDias        : Result := 'Dias';
    mlHoraInicio  : Result := 'Hora inicio';
    mlHoraFin     : Result := 'Hora fin';
    mlTiempoTotal : Result := 'Tiempo total';
    mlDuracCiclo  : Result := 'Duración ciclo';
    mlArchSalida  : Result := 'Archivos de salida';
    mlSalida      : Result := 'Salida';
    mlTodosMuertos: Result := 'Todos los agentes han muerto, se ha detenido la '
                      + 'ejecución de la simulación automáticamente.';
    mlPregDetener : Result := 'Esto provocará que la simulación retorne a su '
                      + 'estado inicial. ¿Está seguro de detener la ejecución';
    mlDirSalNE    : Result := 'El directorio para archivos de salida no existe.'
                      + ' ¿Desea crearlo';
    {Mensajes de error de Galatea}
    mlErrFltEdEs  : Result := 'No se encontró el Editor de Escenarios, se '
                      + 'recomienda reinstalar el paquete Galatea.';
    mlErrFltEdSu  : Result := 'No se encontró el Editor de Sustratos, se '
                      + 'recomienda reinstalar el paquete Galatea.';
    mlErrFltEs    : Result := 'Falta archivo de Escenario.';
    mlErrFltEdAg  : Result := 'No se encontró el Editor de Agentes, se '
                      + 'recomienda reinstalar el paquete Galatea.';
    mlErrFltEdEn  : Result := 'No se encontró el Editor de Entornos, se '
                      + 'recomienda reinstalar el paquete Galatea.';
    mlErrExtNCGL  : Result := 'La extensión del archivo no corresponde a un '
                      + 'proyecto de Galatea.';
    mlFltArchEntrn: Result := 'No se encontró el archivo de entorno';
    mlErrDirSalNC : Result := 'No fue posible crear archivos de salida.';
    mlErrFltAnlzdr: Result := 'No se encontró el analizador de archivos de '
                      + 'salida. Se recomienda reinstalar el paquete Galatea.';
    {Mensajes del Editor de Escenario}
    mlEdEsGl      : Result := 'Editor de Escenarios de Galatea';
    mlEscenario   : Result := 'Escenario';
    mlGrdEsNv     : Result := '¿Desea guardar los cambios en el escenario '
                      + 'actual antes de crear uno nuevo';
    mlGrdEsCr     : Result := '¿Desea guardar los cambios en el escenario '
                      + 'actual antes de cerrarlo';
    mlEscenarios  : Result := 'Escenarios';
    mlDrEsNE      : Result := 'El directorio de escenarios no existe, ¿desea '
                      + 'crearlo';
    mlSustActual  : Result := 'Sustrato actual';
    mlSustMixto   : Result := 'Sustrato mixto';
    {Mensajes de error del Editor de Escenarios}
    //mlErrPrcntjZ  : Result := 'El porcentaje debe ser múltiplo de 20.';
    mlErrFltJS    : Result := 'Falta archivo de juego de sustratos.';
    mlErrExtNCEE  : Result := 'La extensión del archivo no corresponde a un '
                      + 'escenario de Galatea.';
    {Mensajes del Editor de Sustratos}
    mlEdSustGl    : Result := 'Editor de Sustratos de Galatea';
    mlGuardSustNv : Result := '¿Desea guardar los cambios en el juego de '
                      + 'sustratos actual antes de crear uno nuevo';
    mlJgoSustrs   : Result := 'Juego de Sustratos';

    mlGrdSustCr   : Result := '¿Desea guardar los cambios en el juego de '
                      + 'sustratos actual antes de cerrarlo';
    mlSustratos   : Result := 'Sustratos';
    mlDrSustrNE   : Result := 'El directorio de sustratos no existe, '
                      + '¿desea crearlo';
    mlSustrVc     : Result := 'Sustrato vacío';
    mlSgrElmSustr : Result := '¿Está seguro de eliminar el sustrato mixto';
    mlSustrato    : Result := 'Sustrato';
    {Mensajes de error del Editor de Sustratos}
    mlErrExtNCES  : Result := 'La extensión del archivo no corresponde a un '
                      + 'juego de sustratos de Galatea.';
    {Mensajes del Editor de Entornos}
    mlEdEntGlt    : Result := 'Editor de Entornos de Galatea';
    mlEntorno     : Result := 'Entorno';
    mlEntornos    : Result := 'Entornos';
    mlElmntActl   : Result := 'Elemento actual';
    mlGrdEntNv    : Result := '¿Desea guardar los cambios en el entorno actual '
                      + 'antes de crear uno nuevo';
    mlGrdEntCr    : Result := '¿Desea guardar los cambios en el entorno actual '
                      + 'antes de cerrarlo';
    mlDrEntNE     : Result := 'El directorio de entornos no existe, '
                      + '¿desea crearlo';
    mlNoElmntEdt  : Result := 'No hay ningún elemento editable sobre este '
                      + 'cuadro.';
    mlNoCncdStrts : Result := 'Los nombres de sustratos del escenario no '
                      + 'coinciden con los del juego de agentes, se '
                      + 'actualizará el juego de agentes con los nombres de '
                      + 'sustratos del escenario.  Esto no afectará al archivo '
                      + 'de juego de agentes original.';
    mlLcsPtrn     : Result := 'Locus Paterno';
    mlLcsMtrn     : Result := 'Locus Materno';
    mlLcsExprsd   : Result := 'Locus Expresado';
    mlEditarPuesta: Result := 'Editar puesta de huevos';
    mlFltJgAgnts  : Result := 'Falta archivo de juego de agentes';
    {Mensajes de error del Editor de Entornos}
    mlFltEscAsc   : Result := 'No se encontró el escenario asociado.';
    mlFltAgntAsc  : Result := 'No se encontró el juego de agentes asociado.';
    mlErrExtNCEEN : Result := 'La extensión del archivo no corresponde a un '
                      + 'entorno de Galatea.';
    mlNoSlccElmnt : Result := 'No se seleccionó ningún elemento.';
    mlTmnEscnrMnr : Result := 'El tamaño del escenario seleccionado es menor al'
                      + ' actual. Para importar un nuevo escenario es necesario'
                      + ' que su tamaño sea igual o mayor al actual.';
    mlNmrPrttMnr  : Result := 'Para importar un nuevo juego de agentes es '
                      + 'necesario que tanto el número de estadios, prototipos '
                      + 'macho y prototipos hembra sean iguales o mayores al '
                      + 'juego de agentes actual. Esta condición no se '
                      + 'satisface en el juego de agentes seleccionado.';
    mlNMrcCsllSust: Result := 'No se marcó ninguna casilla de sustrato, debe '
                      + 'marcarse al menos una.';
    mlSustNngnCdr : Result := 'Alguno de los sustratos marcados no se '
                      + 'encuentran en ningún cuadro del entorno, desmarque la '
                      + 'casilla correspondiente al sustrato: ';
    mlNoElmntOvps : Result := 'No hay ningún agente adulto o sitio de '
                      + 'oviposición en este cuadro.';
    mlNvlMxHvs    : Result := 'El número máximo de huevos almacenados en este '
                      + 'sitio de oviposición sería rebasado con la cantidad '
                      + 'de huevos solicitada. No se creará la puesta.';
    {Mensajes del Editor de Agentes}
    mlEdAgntGlt   : Result := 'Editor de Agentes de Galatea';
    mlJgoAgnts    : Result := 'Juego de Agentes';
    mlGrdAgntNv   : Result := '¿Desea guardar los cambios en el juego de '
                      + 'agentes actual antes de crear uno nuevo';
    mlGrdAgntCr   : Result := '¿Desea guardar los cambios en el juego de '
                      + 'agentes actual antes de cerrarlo';
    mlDrAgntNE    : Result := 'El directorio de agentes no existe, ¿desea'
                      + ' crearlo';
    mlAgente      : Result := 'Agente';
    mlAgentes     : Result := 'Agentes';
    mlVarianza    : Result := 'Varianza';
    mlDiscreto    : Result := 'Discreto';
    mlContinuo    : Result := 'Continuo';
    mlConducta    : Result := 'Conducta';
    mlCosto       : Result := 'Costo';
    mlMinimo      : Result := 'Mínimo';
    mlCritico     : Result := 'Crítico';
    mlOptimo      : Result := 'Óptimo';
    mlInicial     : Result := 'Inicial';
    mlMaximo      : Result := 'Máximo';
    mlNutrimentos : Result := 'Nutrimentos';
    mlRqrmnts     : Result := 'Requerimientos';
    mlCostos      : Result := 'Costos';
    mlElmnrPrttp  : Result := '¿Esta seguro de eliminar el prototipo';
    mlElmnrEstd   : Result := '¿Está seguro de eliminar el estadio';
    mlBeber       : Result := 'Beber';
    mlCmrGrasa    : Result := 'Comer lípidos';
    mlCmrAzucar   : Result := 'Comer carbohidratos';
    mlCmrProteina : Result := 'Comer proteina';
    mlTasaMutacion: Result := 'Tasa de mutacion';
    mlRsltFrml    : Result := 'El resultado de la fórmula, según los valores '
                                + 'propuestos es:';
    mlOvipositar  : Result := 'Ovipositar';
    mlDblClcEdCl  : Result := 'Doble clic para editar celda.';
    mlDblClcEdFr  : Result := 'Doble clic sobre controles color crema para '
                                + 'abrir editor de fórmulas.';
    mlDesplegar   : Result := 'Desplegar';
    mlEscalar     : Result := 'Escalar';
    mlRetirar     : Result := 'Retirar';
    mlIA          : Result := 'Intento Desplegado';
    mlIB          : Result := 'Intento Escalado';
    mlCopular     : Result := 'Copular';
    mlRechazar    : Result := 'Rechazar';
    mlDominante   : Result := 'Dominante';
    mlRecesivo    : Result := 'Recesivo';
    mlOperador    : Result := 'Operador';
    mlFormula     : Result := 'Fórmula';
    mlRangoMut    : Result := 'Rango mutación';
    mlEstadio     : Result := 'Estadio';
    mlEstadios    : Result := 'Estadios';
    mlPrttMachos  : Result := 'Prototipos machos';
    mlPrttHembras : Result := 'Prototipos hembras';
    mlLociCont    : Result := 'Loci continuos';
    mlLociDisc    : Result := 'Loci discretos';
    mlCarCont     : Result := 'Caracteres continuos';
    mlCarDisc     : Result := 'Caracteres discretos';
    mlMaxHuevos   : Result := 'Máximo número de huevo';
    mlMaxEsperma  : Result := 'Máximo número de paquetes espermáticos';
    mlCostoUnidad : Result := 'Costos por unidad';
    mlNtrmntUndds : Result := 'Unidades de nutrimentos tomadas';
    mlNmrPETC     : Result := 'Número de paquetes espermáticos transferidos por'
                                + ' cópula';
    mlMaxPEAH     : Result := 'Número máximo de paquetes espermáticos '
                                + 'almacenados por la hembra';
    mlTasaConsmPE : Result := 'Tasa de consumo del paquete espermático';
    mlFrccHFC     : Result := 'Fracción de huevos fertilizados justo después '
                                + 'de la cópula';
    mlPrbbPtrnd   : Result := 'Probabilidad de paternidad';
    mlHvsOvpstd   : Result := 'Huevos ovipositados por ciclo';
    mlPrddPE      : Result := 'Valor energético del paquete espermático '
                                + 'perdido para el uso de la hembra';
    mlPrddHv      : Result := 'Valor energértico perdido para uso del agente';
    mlCambrEst    : Result := 'Cambiar a siguiente estadio a la edad de';
    mlYOReqrmnts  : Result := 'y/o cubrir los requerimientos';
    mlLongevidad  : Result := 'Longevidad';
    mlAsgncnSx    : Result := 'Asignación sexual asociada (M:H)';
    mlRfrctr      : Result := 'Periodo refractario';
    mlEstrtgCombt : Result := 'Estrategia combate';
    mlEstrtgCortj : Result := 'Estrategia cortejo';
    mlCrtrsAsgnc  : Result := 'Criterios de asignación de prototipo';
    mlAsgncnJrrq  : Result := 'Jerarquía de asignación de prototipos';
    mlMatrizInt   : Result := 'Matriz de interacción';
    mlMatrizAtr   : Result := 'Matriz de atractividad';
    mlMatrizMem   : Result := 'Matriz de memoria';
    mlMatrizMemCon: Result := 'Matriz de memoria de conducta';
    mlEdFormls    : Result := 'Editor de Fórmulas';
    mlPeleaGanada : Result := 'Pelea Ganada';
    mlPeleaPerdida: Result := 'Pelea Perdida';
    mlRefractario : Result := 'Refractario';
    mlMemoria     : Result := 'Memoria';
    mlMetabolismo : Result := 'Metabolismo';
    mlFisiologia  : Result := 'Fisiología';
    mlPrdccnGmts  : Result := 'Producción de gametos';
    mlPrdEnrgtc   : Result := 'Pérdida energética';
    mlMorfologia  : Result := 'Morfología';
    mlLlnrCld     : Result := 'Llenar celda';
    mlMorir       : Result := 'Morir';
    mlAtractividad: Result := 'Atractividad';
    mlRdPrcpcn    : Result := 'Radio de percepción';
    mlIniTdsClds  : Result := 'Inicializar todas las celdas con:';
    mlCondicion   : Result := 'Condición';
    mlTndncsMvmnt : Result := 'Tendecias de movimiento';
    mlAceptacion  : Result := 'Aceptación';
    mlDegrEsperma : Result := 'Tasa de degradación de esperma';
    mlDinGam      : Result := 'Dinámica de gametos';
    {Mensajes de error del Editor de Agentes}
    mlErrExtNCEA  : Result := 'La extensión del archivo no corresponde a un '
                      + 'juego de agentes de Galatea.';
    mlErrMtcnMnr1 : Result := 'El valor de tasa de mutación debe estar entre 0 '
                      + 'y 1.';
    mlErrFltPlnt  : Result := 'No especificó un nombre de plantilla.';
    {Mensajes del Analizador de Salidas}
    mlAnlzdrSlds  : Result := 'Analizador de Salidas';
  else
    Result := '';
  end; //case
end;  //MLEspanol

function MLEnglish(Indice: TMensajeIndice): string;
begin
  case Indice of
    {Mensajes generales}
    mlHola        : Result := 'Hello';
    mlSnTtl       : Result := 'Untitled';
    mlNum         : Result := 'Number';
    mlNombre      : Result := 'Name';
    mlDefecto     : Result := 'Default';
    mlPropiedades : Result := 'Properties';
    mlAgua        : Result := 'Water';
    mlAzucar      : Result := 'Carbohidrates';
    mlGrasa       : Result := 'Lipids';
    mlProteina    : Result := 'Protein';
    mlMovimiento  : Result := 'Movement';
    mlEnReposo    : Result := 'At rest';
    mlMacho       : Result := 'Male';
    mlHembra      : Result := 'Female';
    mlHuevo       : Result := 'Egg';
    mlInmaduro    : Result := 'Immature';
    mlCaracter    : Result := 'Character';
    mlValor       : Result := 'Value';
    mlDinamico    : Result := 'Dynamic E.';
    mlEmisor      : Result := 'Issuer';
    mlReceptor    : Result := 'Receiver';
    mlFntAgua     : Result := 'Water Source';
    mlFntAzucar   : Result := 'Carbohidrates Source';
    mlFntGrasa    : Result := 'Lipids Source';
    mlFntPrtn     : Result := 'Protein Source';
    mlSitOvipo    : Result := 'Oviposition Site';
    mlValores     : Result := 'Values';
    mlVelocidad   : Result := 'Speed';
    mlNinguno     : Result := 'None';
    mlPrototipo   : Result := 'Prototype';
    mlPrototipos  : Result := 'Prototypes';
    mlColor       : Result := 'Color';
    mlY           : Result := 'and';
    mlO           : Result := 'or';
    mlAdulto      : Result := 'Adulto';
    mlCrctrstcs   : Result := 'Features';
    mlCombate     : Result := 'Fighting';
    mlCortejo     : Result := 'Mating';
    mlMachos      : Result := 'Males';
    mlHembras     : Result := 'Females';
    mlDinamicos   : Result := 'Dynamic elements';
    mlNS          : Result := 'N-S';
    mlEO          : Result := 'E-W';
    mlNO          : Result := 'NW';
    mlW           : Result := 'W';
    mlSO          : Result := 'SW';
    mlUltInt      : Result := 'Last interaction ';
    mlNumInt      : Result := 'Number interactions ';
    mlUltVz       : Result := 'Last time ';
    mlNumVcs      : Result := 'Number times ';
    mlPqtEsprmtc  : Result := 'Sperm pack';
    mlForrajeo    : Result := 'Foraging';
    mlRprdccn     : Result := 'Reproduction';
    mlContendiente: Result := 'Contender';
    mlUltPer      : Result := 'Last perception ';
    mlNumPer      : Result := 'Number perceptions ';
    mlIndefinido  : Result := 'Undefined';
    mlCiclos      : Result := 'Cycles';
    mlGenetico    : Result := 'Genetic';
    mlAmbiental   : Result := 'Environmental';
    {Mensajes generales de error}
    mlErrNVld     : Result := 'Especified value is incorrect.';
    mlErrSm100    : Result := 'The sum of the percentages should be equal to '
                      + '100.';
    mlErrArchvNE  : Result := 'The file does not exist';
    mlErrMinPer   : Result := 'The minimum permitted value is ';
    mlErrMaxPer   : Result := 'The maximun permitted value is ';
    mlErrNeg      : Result := 'Value must be positive.';
    mlErrFracc    : Result := 'Value must be between 0 and 1.';
    {Mensajes del Editor de Escenario}
    mlEdEsGl      : Result := 'Galatea Stage Editor';
    mlEscenario   : Result := 'Stage';
    mlGrdEsNv     : Result := 'Do you want to save the changes in the current '
                      + 'stage before creating one new?';
    mlGrdEsCr     : Result := 'Do you want to save the changes in the current '
                      + 'stage before close it';
    mlEscenarios  : Result := 'Stages';
    mlDrEsNE      : Result := 'The directory of stages does not exist, do you '
                      + 'want to create it';
    mlSustActual  : Result := 'Current substrate';
    mlSustMixto   : Result := 'Mixed substrate';
    {Mensajes de Galatea}
    mlProyecto    : Result := 'Project';
    mlProyectos   : Result := 'Projects';
    mlGrdProyNv   : Result := 'Do you want to save the changes in the current '
                      + 'project before creating one new';
    mlGrdProyCr   : Result := 'Do you want to save the changes in the current '
                      + 'project before close it';
    mlDrProyNe    : Result := 'The directory of projects does not exist, do '
                      + 'you want to create it';
    mlFechaInicio : Result := 'Start date';
    mlFechaFin    : Result := 'Finish date';
    mlSegundos    : Result := 'Seconds';
    mlMinutos     : Result := 'Minutes';
    mlHoras       : Result := 'Hours';
    mlDias        : Result := 'Days';
    mlHoraInicio  : Result := 'Start time';
    mlHoraFin     : Result := 'Finish time';
    mlTiempoTotal : Result := 'Total time';
    mlDuracCiclo  : Result := 'Cycle duration';
    mlArchSalida  : Result := 'Output files';
    mlSalida      : Result := 'Output';
    mlTodosMuertos: Result := 'All agents have died, simulation running has '
                        + 'stopped automatically.';
    mlPregDetener : Result := 'This will cause that the simulation returns to '
                        + 'its initial state. Are you sure of stopping the '
                        + 'execution';
    mlDirSalNE    : Result := 'The directory of output files does not exist, do'
                        + ' you want to create it';
    {Mensajes de error de Galatea}
    mlErrFltEdEs  : Result := 'Stage Editor not found, reinstaling Galatea '
                      + 'package is recomended.';
    mlErrFltEdSu  : Result := 'Substrate Editor not found, reinstaling Galatea'
                      + ' package is recomended.';
    mlErrFltEs   : Result := 'Missing stage file.';
    mlErrFltEdAg  : Result := 'Agent Editor not found, reinstaling Galatea'
                      + ' package is recomended.';
    mlErrFltEdEn  : Result := 'Environment Editor not found, reinstaling '
                      + 'Galatea package is recomended.';
    mlErrExtNCGL  : Result := 'File extension does not match with a Galatea '
                      + 'project.';
    mlFltArchEntrn: Result := 'Environment file not found';
    mlErrDirSalNC : Result := 'It was not possible to create output files.';
    mlErrFltAnlzdr: Result := 'Output files analizer not found, reinstaling '
                      + 'Galatea package is recomended.';
    {Mensajes de error del Editor de Escenarios}
    mlErrFltJS    : Result := 'Missing set of substrates file.';
    mlErrExtNCEE  : Result := 'File extension does not match with a Galatea '
                      + 'stage.';
    {Mensajes del Editor de Sustratos}
    mlEdSustGl    : Result := 'Galatea Substrate Editor';
    mlGuardSustNv : Result := 'Do you want to save the changes in the current '
                      + 'set of substrates before creating one new';
    mlJgoSustrs   : Result := 'Set of Substrates';
    mlGrdSustCr   : Result := 'Do you want to save the changes in the current '
                      + 'set of substrates before close it';
    mlSustratos   : Result := 'Substrates';
    mlDrSustrNE   : Result := 'The directory of substrates does not exist, '
                      + 'do you want to create it';
    mlSustrVc     : result := 'Empty substrate';
    mlSgrElmSustr : Result := 'Are you sure of removing the mixed substrate';
    mlSustrato    : Result := 'Substrate';
    {Mensajes de error del Editor de Sustratos}
    mlErrExtNCES  : Result := 'File extension does not match with a Galatea set '
                      + 'of substrates.';
    {Mensajes del Editor de Entornos}
    mlEdEntGlt    : Result := 'Galatea Environment Editor';
    mlEntorno     : Result := 'Environment';
    mlEntornos    : Result := 'Environments';
    mlElmntActl   : Result := 'Current element';
    mlGrdEntNv    : Result := 'Do you want to save the changes in the current '
                      + 'environment before creating one new';
    mlGrdEntCr    : Result := 'Do you want to save the changes in the current '
                      + 'environment before close it';
    mlDrEntNE     : Result := 'The directory of environments does not exist, '
                      + 'do you want to create it';
    mlNoElmntEdt  : Result := 'There is no element to edit on this square.';
    mlNoCncdStrts : Result := 'The names of substrates in this stage do not '
                      + 'coincide with those of the set of agents, the set of '
                      + 'agents will be upgraded with the names of substrates '
                      + 'of this stage.  This will not afect the original set '
                      + 'of agents file.';
    mlLcsPtrn     : Result := 'Paternal Locus';
    mlLcsMtrn     : Result := 'Maternal Locus';
    mlLcsExprsd   : Result := 'Expressed Locus';
    mlEditarPuesta: Result := 'Edit egg clutch properties';
    mlFltJgAgnts  : Result := 'Missing set of agents file';
    {Mensajes de error del Editor de Entornos}
    mlFltEscAsc   : Result := 'Associate stage not found.';
    mlFltAgntAsc  : Result := 'Associate set of agents not found.';
    mlErrExtNCEEN : Result := 'File extension does not match with a Galatea '
                      + 'environment.';
    mlNoSlccElmnt : Result := 'You must select an element.';
    mlTmnEscnrMnr : Result := 'The size of the selected stage is smaller to the'
                      + ' current one. To import a new stage it is necessary'
                      + ' that their size is the same or bigger than the '
                      + 'current stage.';
    mlNmrPrttMnr   : Result := 'To import a new set of agents it is necessary '
                      + 'that the number of life stages, male prototypes and '
                      + 'female prototypes are the same or higher than in the '
                      + 'current set of agents. This condition is not met in '
                      + 'the selected set of agents.';
    mlNMrcCsllSust: Result := 'No substrate checkbox was marked, at least one '
                      + 'should be marked.';
    mlSustNngnCdr : Result := 'Some of the marked substrates is not in any '
                      + 'square of the environment, uncheck the checkbox '
                      + 'corresponding to the substrate: ';
    mlNoElmntOvps : Result := 'There is no adult agent or oviposition site '
                      + 'on this squar.';
    mlNvlMxHvs    : Result := 'The maximum number of eggs stored in this '
                      + 'oviposition site would be surpassed with the quantity '
                      + 'of eggs requested. The clutch will not be created.';
    {Mensajes del Editor de Agentes}
    mlEdAgntGlt   : Result := 'Galatea Agent Editor';
    mlJgoAgnts    : Result := 'Set of Agents';
    mlGrdAgntNv   : Result := 'Do you want to save the changes in the current '
                      + 'set of agents before creating one new';
    mlGrdAgntCr   : Result := 'Do you want to save the changes in the current '
                      + 'set of agents before close it';
    mlDrAgntNE    : Result := 'The directory of agents does not exist, '
                      + ' do you want to create it';
    mlAgente      : Result := 'Agent';
    mlAgentes     : Result := 'Agents';
    mlVarianza    : Result := 'Variance';
    mlDiscreto    : Result := 'Discrete';
    mlContinuo    : Result := 'Continuous';
    mlConducta    : Result := 'Behavioral pattern';
    mlCosto       : Result := 'Cost';
    mlMinimo      : Result := 'Minimum';
    mlCritico     : Result := 'Critical';
    mlOptimo      : Result := 'Optimum';
    mlInicial     : Result := 'Initial';
    mlMaximo      : Result := 'Maximum';
    mlNutrimentos : Result := 'Nutrients';
    mlRqrmnts     : Result := 'Requirements';
    mlCostos      : Result := 'Costs';
    mlElmnrPrttp  : Result := 'Are you sure you want to remove the prototype';
    mlElmnrEstd   : Result := 'Are you shure you want to remove life stage';
    mlBeber       : Result := 'Drink';
    mlCmrGrasa    : Result := 'Eat lipds';
    mlCmrAzucar   : Result := 'Eat carbohidrates';
    mlCmrProteina : Result := 'Eat protein';
    mlTasaMutacion: Result := 'Mutation rate';
    mlRsltFrml    : Result := 'Formula result, according to proposed values'
                                + ' is:';
    mlOvipositar  : Result := 'Oviposite';
    mlDblClcEdCl  : Result := 'Double click for cell editing';
    mlDblClcEdFr  : Result := 'Double click over cream color controls for '
                                + 'opening formula editor.';
    mlDesplegar   : Result := 'Display';
    mlEscalar     : Result := 'Escalate';
    mlRetirar     : Result := 'Retreat';
    mlIA          : Result := 'Display Attempt';
    mlIB          : Result := 'Escalate Attempt';
    mlCopular     : Result := 'Copulate';
    mlRechazar    : Result := 'Reject';
    mlDominante   : Result := 'Dominant';
    mlRecesivo    : Result := 'Recessive';
    mlOperador    : Result := 'Operator';
    mlFormula     : Result := 'Formula';
    mlRangoMut    : Result := 'Mutation range';
    mlEstadio     : Result := 'Life stage';
    mlEstadios    : Result := 'Life stages';
    mlPrttMachos  : Result := 'Male prototypes';
    mlPrttHembras : Result := 'Female prototypes';
    mlLociCont    : Result := 'Continuos loci';
    mlLociDisc    : Result := 'Discretes loci';
    mlCarCont     : Result := 'Continuous characters';
    mlCarDisc     : Result := 'Discretes characters';
    mlMaxHuevos   : Result := 'Max number of eggs';
    mlMaxEsperma  : Result := 'Max number of sperm packs';
    mlCostoUnidad : Result := 'Costs per unit';
    mlNtrmntUndds : Result := 'Nutrient units taken';
    mlNmrPETC     : Result := 'Number of sperm packs given per copula';
    mlMaxPEAH     : Result := 'Max number of sperm packs stored by female';
    mlTasaConsmPE : Result := 'Consuption rate of sperm pack';
    mlFrccHFC     : Result := 'Fraction of eggs fertilized just after copula';
    mlPrbbPtrnd   : Result := 'Probability of paternity';
    mlHvsOvpstd   : Result := 'Eggs oviposited per cycle';
    mlPrddPE      : Result := 'Sperm pack energetic value lost for female use';
    mlPrddHv      : Result := 'Egg energetic value lost for  agent use';
    mlCambrEst    : Result := 'Change to next life at age';
    mlYOReqrmnts  : Result := 'and/or cover requirements';
    mlLongevidad  : Result := 'Longevity';
    mlAsgncnSx    : Result := 'Sex allocation associated (M:F)';
    mlRfrctr      : Result := 'Refractory period';
    mlEstrtgCombt : Result := 'Fighting strategy';
    mlEstrtgCortj : Result := 'Mating strategy';
    mlCrtrsAsgnc  : Result := 'Prototype allocation criteria';
    mlAsgncnJrrq  : Result := 'Prototype allocation hyerarchy';
    mlMatrizInt   : Result := 'Interaction matrix';
    mlMatrizAtr   : Result := 'Attractivity matrix';
    mlMatrizMem   : Result := 'Memory matrix';
    mlMatrizMemCon: Result := 'Behavioral memory matrix';
    mlEdFormls    : Result := 'Formula Editor';
    mlPeleaGanada : Result := 'Won Fight';
    mlPeleaPerdida: Result := 'Lost Fight';
    mlRefractario : Result := 'Refractory';
    mlMemoria     : Result := 'Memory';
    mlMetabolismo : Result := 'Metabolism';
    mlFisiologia  : Result := 'Physiology';
    mlPrdccnGmts  : Result := 'Gamete production';
    mlPrdEnrgtc   : Result := 'Energetic lossing';
    mlMorfologia  : Result := 'Morphology';
    mlLlnrCld     : Result := 'Fill cell';
    mlMorir       : Result := 'Die';
    mlAtractividad: Result := 'Atractivity';
    mlRdPrcpcn    : Result := 'Perception radius';
    mlIniTdsClds  : Result := 'Initialize all cells with:';
    mlCondicion   : Result := 'Condition';
    mlTndncsMvmnt : Result := 'Motion tendencies';
    mlAceptacion  : Result := 'Receptiveness';
    mlDegrEsperma : Result := 'Rate of sperm degradation';
    mlDinGam      : Result := 'Gametes dynamic';
    {Mensajes de error del Editor de Agentes}
    mlErrExtNCEA  : Result := 'File extension does not match with a Galatea set'
                                  + ' of agents.';
    mlErrMtcnMnr1 : Result := 'Mutation rate value must be between 0 and 1.';
    mlErrFltPlnt  : Result := 'Missing template name.';
    {Mensajes del Analizador de Salidas}
    mlAnlzdrSlds  : Result := 'Output analizer';
  else
    Result := '';
  end; //case
end; //MLEnglish

function ML(Indice: TMensajeIndice): string;
begin
  case Lenguaje of
    lEspanol: Result := MLEspanol(Indice);
    lEnglish: Result := MLEnglish(Indice);
  else
    Result := '';
  end;
end;

end.
