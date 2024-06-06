//Código para calcular el histograma asociado al uso de suelo para una geometría.

//Obtiene la base de datos a usar entre el 2001 y el 2022 
//MCD12Q1.061: MODIS Land Cover Type Yearly Global 500m

var MCD12Q1 = ee.ImageCollection("MODIS/061/MCD12Q1")
              .filterDate('2001-01-01', '2022-01-01');

//Se debe generar una geometria (polígono  punto) de donde se obtendrá el
//promedio de la serie de datos.

var lista_HRUs = ['aguas_abajo_lago_ranco', 'aguas_arriba_lago_ranco',
                  'B01','B02','B03','B04','B05',
                  'cuenca_rio_bueno_en_bueno',
                  'HRU_A_1','HRU_A_2','HRU_A_3','HRU_A_4',
                  'HRU_B_1','HRU_B_2','HRU_B_3','HRU_B_4','HRU_B_5',
                  'HRU_B01_1','HRU_B01_2','HRU_B01_3','HRU_B01_4','HRU_B01_5',
                  'HRU_B02_1','HRU_B02_2','HRU_B02_3','HRU_B02_4',
                  'HRU_B03_1','HRU_B03_2','HRU_B03_3','HRU_B03_4','HRU_B03_5',
                  'HRU_B04_1','HRU_B04_2','HRU_B04_3','HRU_B04_4',
                  'HRU_B05_1','HRU_B05_2','HRU_B05_3','HRU_B05_4']

for (var i = 0; i < lista_HRUs.length; i++) {

    var stringHRU = lista_HRUs[i]; //Definir HRU o banda de elevación

    var  HRU = ee.FeatureCollection('projects/ee-jvaldivieso/assets/diplomado_2024/'+stringHRU);

    // Seleccionar la banda de clasificación de uso del suelo
    var banda_uso_suelo = 'LC_Type1';

    // Filtrar la colección a una sola imagen
    var imagen = MCD12Q1.first();

    // Recortar la imagen a la región de interés
    imagen = imagen.clip(HRU);

    // Calcular la frecuencia de cada clase de uso del suelo en la región de interés
    var frecuencia = imagen.reduceRegion({
      reducer: ee.Reducer.frequencyHistogram(),
      geometry: HRU,
      scale: 500 // Ajusta la escala según tus necesidades
    });

    // Obtener la propiedad con el histograma de frecuencia
    var histograma = ee.Dictionary(frecuencia.get('LC_Type1'));

    print('HRU',lista_HRUs[i]);
    print('area [ha]', HRU.geometry().area().divide(10000));
    print('histograma',histograma);

}
