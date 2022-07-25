﻿Процедура ПлатежноеПоручениеПриСозданииНаСервере(Объект, Форма) Экспорт
	
	 Затр_ПриСозданииНаСервере(Форма, Объект.Ссылка, Форма.Элементы.ГруппаПолучатель)
	
 КонецПроцедуры
 
 Процедура ПлатежноеПоручениеКонтрагентПриИзменении(КонтрагентСсылка, Объект, Форма) Экспорт
	 
	// 1. получить все доп сведения контрагента
	ТаблицаСвойств = УправлениеСвойствами.ЗначенияСвойств(КонтрагентСсылка, Ложь, Истина, );

	// 2. заполнить доп сведения контрагента как значения по умолчанию
	Если Объект.Ссылка.Пустая() Тогда		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Необходимо записать документ!");
		Возврат;
	КонецЕсли;	
	
	Для Каждого Свойство Из ТаблицаСвойств Цикл
		Попытка
			Затр_ЗаписатьСведенияНаСервере(Объект.Ссылка, Свойство.ИмяСвойства, Свойство.Значение);	 
			Форма[Свойство.ИмяСвойства] = Свойство.Значение;
			//Форма.ОбновитьОтображениеДанных(Форма.Элементы[Свойство.ИмяСвойства]);
		Исключение
			// нет такого свойства или нет реквизита формы
		КонецПопытки;
	КонецЦикла; 
	 
 КонецПроцедуры

Процедура Затр_ЗаписатьСведенияНаСервере(Ссылка, ИмяСвойства, Значение) Экспорт
	
	ТаблицаСвойствИЗначений = Новый ТаблицаЗначений;
	ТаблицаСвойствИЗначений.Колонки.Добавить("Свойство");
	ТаблицаСвойствИЗначений.Колонки.Добавить("Значение");
	
	НоваяСтрока = ТаблицаСвойствИЗначений.Добавить();
	Свойства = УправлениеСвойствами.СвойстваОбъекта(Ссылка, Ложь, Истина);
	Для Каждого Свойство Из Свойства Цикл
		Если Свойство.Имя = ИмяСвойства Тогда
			НоваяСтрока.Свойство = Свойство;	
		КонецЕсли;	
	КонецЦикла;	
	НоваяСтрока.Значение = Значение;
	
	УправлениеСвойствами.ЗаписатьСвойстваУОбъекта(Ссылка, ТаблицаСвойствИЗначений); 
	
КонецПроцедуры	

Процедура Затр_ПриСозданииНаСервере(Форма, Ссылка, ГруппаФормы) Экспорт
	
	// вывести доп сведения в форму как доп реквизит
	ДобавляемыеРеквизиты = Новый Массив;
	
	СписокСвойств = УправлениеСвойствами.ПолучитьСписокСвойств(Ссылка, Ложь, Истина);
	Для Каждого Свойство Из СписокСвойств Цикл   
		
		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы(Свойство.Имя, Свойство.ТипЗначения, "", Свойство.Заголовок, Ложь));
		
	КонецЦикла;	
	
	Форма.ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	
	Для Каждого Свойство Из СписокСвойств Цикл
		
		ЗначенияСвойства = УправлениеСвойствами.ЗначенияСвойств(Ссылка, 
			Ложь, 
			Истина, 
			ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Свойство),
		);
		Если НЕ ЗначенияСвойства.Количество() = 0 Тогда
			Форма[Свойство.Имя] = ЗначенияСвойства[0].Значение;
		КонецЕсли;
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	С.Ссылка КАК Значение
		|ИЗ
		|	Справочник.ЗначенияСвойствОбъектов КАК С
		|ГДЕ
		|	С.Владелец = &Свойство
		|	И НЕ С.ПометкаУдаления";
		Запрос.УстановитьПараметр("Свойство", Свойство);
		ТаблицаДоступныхЗначенийСвойства = Запрос.Выполнить().Выгрузить();
		
		НовоеПолеФормы = Форма.Элементы.Добавить(Свойство.Имя, Тип("ПолеФормы"), ГруппаФормы);
		НовоеПолеФормы.ПутьКДанным = Свойство.Имя;
		НовоеПолеФормы.Вид = ВидПоляФормы.ПолеВвода;
		НовоеПолеФормы.КнопкаСоздания = Ложь;
		НовоеПолеФормы.РежимВыбораИзСписка = Истина;
		НовоеПолеФормы.СписокВыбора.ЗагрузитьЗначения(ТаблицаДоступныхЗначенийСвойства.ВыгрузитьКолонку("Значение"));
		НовоеПолеФормы.УстановитьДействие("ПриИзменении", "Затр_Подключаемый_ПриИзмененииДополнительногоСведения");
		
	КонецЦикла;	
	
КонецПроцедуры
