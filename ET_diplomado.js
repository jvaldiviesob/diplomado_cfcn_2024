//Código para estimar los componentes de la ET en un sitio específico.

//Obtiene la base de datos a usar entre el 2002 y el 2017 
//PML_V2 0.1.7: Coupled Evapotranspiration and Gross Primary Product (GPP) 
 
var PML_V2 = ee.ImageCollection("CAS/IGSNRR/PML/V2_v017")
              .filterDate('2000-02-26', '2020-12-26');

//Obtiene la base de datos a usar entre el 2001 y el 2024 
//MOD16A2.061: Terra Net Evapotranspiration 8-Day Global 500m

var MOD16A2 = ee.ImageCollection("MODIS/061/MOD16A2")
              .filterDate('2001-01-01', '2024-05-30');
              

//Se debe generar una geometria (polígono  punto) de donde se obtendrá el
//promedio de la serie de datos.

var stringHRU = 'cuenca_rio_bueno_en_bueno'; //Definir HRU o banda de elevación

var  HRU = ee.FeatureCollection('projects/ee-jvaldivieso/assets/diplomado_2024/'+stringHRU);

//Visualizar HRU en el mapa.

Map.addLayer(HRU, {color: "DF0101"}, stringHRU);
Map.centerObject(HRU, 8);

//Obtener escada de las bandas del producto MODIS de ET

var escala_ET = ee.Number(0.1),
    escala_LE = ee.Number(10000.0),
    escala_PET = ee.Number(0.1),
    escala_PLE = ee.Number(10000.0);
    
    
var densidadAgua = ee.Number(1000.0), // kg/m^3
    gravedadEspecificaAgua = ee.Number(1.0),
    factor = ee.Number(1.0).divide(densidadAgua.multiply(gravedadEspecificaAgua));





// Crea un gráfico para la HRU de las componentes del producto PML_V2. 
// Se omite el GPP por no ser de interés, pero se puede agregar de ser necesario.

var chart_PML_V2_HRU = ui.Chart.image.series({
  imageCollection: PML_V2.select('Ec', 'Es', 'Ei', 'ET_water'),
  region: HRU,
  reducer: ee.Reducer.mean(),
  scale: 500
}).setOptions({title: 'PML_V2 - '+stringHRU+' - Componentes de la ET'});

// Crea un gráfico para la HRU de las bandas del producto MODIS.

var chart_MOD16A2_HRU = ui.Chart.image.series({
  imageCollection: MOD16A2.select('ET', 'LE', 'PET', 'PLE'),
  region: HRU,
  reducer: ee.Reducer.mean(),
  scale: 500
}).setOptions({title: 'MOD16A2 - '+stringHRU+' - Componentes de la ET'});


// Crea un gráfico para cada HRU de la ET de MODIS.

var chart_MOD16A2_ET_HRU = ui.Chart.image.series({
  imageCollection: MOD16A2.select('ET'),
  region: HRU,
  reducer: ee.Reducer.mean(),
  scale: 500
}).setOptions({title: 'MOD16A2 - '+stringHRU+' - ET [mm/dia]'});


// Mostrar los gráficos de PML_V2 en la consola.

print(chart_PML_V2_HRU);

// Mostrar los gráficos de MOD16A2 en la consola.

print('Ojo! La ET de MODIS hay que multiplicarla');
print('por el siguiente factor para obtener la ET');
print('en mm/dia desde kg/m^2/8dia (escalado):');
//AYUDA!! no sé cuanto es! print(factor.multiply(escala_ET).multiply(8.0))!!;


print(chart_MOD16A2_HRU);

// Mostrar los gráficos de MOD16A2 (ET) en la consola.

print(chart_MOD16A2_ET_HRU);

//PML_V2 https://developers.google.com/earth-engine/datasets/catalog/CAS_IGSNRR_PML_V2_v017#bands
//Name	Units	Min	Max	Description
//GPP	gC m-2 d-1	0*	39.01* Gross primary product
//Ec	mm/d	0*	15.33* Vegetation transpiration
//Es	mm/d	0*	8.2* Soil evaporation
//Ei	mm/d	0*	12.56* Interception from vegetation canopy
//ET_water	mm/d	0*	20.11* Water body, snow and ice evaporation. Penman evapotranspiration is regarded as actual evaporation for them. * estimated min or max value

//MOD16A2.061 //https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MOD16A2
//Name	Units	Min	Max	Scale	Description
//ET	kg/m^2/8day	-32767	32700	0.1	Total evapotranspiration
//LE	J/m^2/day	-32767	32700	10000	Average latent heat flux
//PET	kg/m^2/8day	-32767	32700	0.1	Total potential evapotranspiration
//PLE	J/m^2/day	-32767	32700	10000	Average potential latent heat flux
//ET_QC Evapotranspiration quality control flags
