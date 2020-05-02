# Конфигурирование загрузки

##Сброс пароля способ первый:

![Редактируем параметры загрузки:](https://github.com/Swenum/otus/blob/master/Dz6_boot_sys/Screenshot_1.png "Редактируем параметры загрузки")
В ro заменяем o → w и добавляем init=/sysroot/bin/sh после rw.
Монтируем системный раздел
chroot /sysroot
![Устанавливаем пароль:](https://github.com/Swenum/otus/blob/master/Dz6_boot_sys/Screenshot_2.png "Устанавливаем пароль")
Меняем пароль.
![Selinux flag:](https://github.com/Swenum/otus/blob/master/Dz6_boot_sys/Screenshot_3.png "Selinux")
Создаём файл-флаг для SELinux командой touch /.autorelabel
чтобы пересчитались все маркеры безопасности.

##Сброс пароля, способ второй:
Загружаем систему с другого носителя:

![Reset pass:](https://github.com/Swenum/otus/blob/master/Dz6_boot_sys/Screenshot_4.png "Сбрасываем пароль")
Сбрасываем пароль, загрузившись с другой операционной системы и\или другого носителя
Входим в ситему, монтируем LVM, chroot'тимся в него, меняем пароль, делаем флаг для  Selinux пересчитать маркёры безопасности,
выходим из chroot, отмонтируем файловую систему. Перезапускаемся и получаем систему со сброшенным паролем.
Это основной способ для облачных провайдеров, где доступ к консоли невозможен или затруднён.

##Получение доступа в сиcтему без смены пароля

![Catch_the_system:](https://github.com/Swenum/otus/blob/master/Dz6_boot_sys/Screenshot_5.png "Доступ к ситеме")

Разница в способах описанных в практике - в том что мы меняем пароль через emergency  или обходим проверку пароля и загружаем 
систему без смены пароля.
