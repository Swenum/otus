# 1. Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников

добавляем модули в /etc/pam.d/sshd

Ограничения по времени pam_time.so

```bash
account required pam_access.so
account required pam_time.so
```

 
Запретить группе правила входа по времени не получилось.
Комбинация нескольких модулей.
 /etc/pam.d/login
```bash
account    [success=1 default=ignore] pam_succeed_if.so user ingroup admin
account    required     pam_time.so
```
Добавляем запись в  /etc/security/time.conf запрещающую логин в выходные
```bash
login;*;*;Wk0000-2400
```


# 2. Дать конкретному пользователю права работать с докером  и возможность рестартить докер сервис

Добавляем пользователя admin в группу docker
```bash
usermod -G docker admin
```

Через Polkit предоставляем права на рестарт сервиса 
```
/etc/polkit-1/rules.d/01-restart-docker.rules 
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.systemd1.manage-units") {
        if (action.lookup("unit") == "docker.service" && subject.user === "admin"){
            if (action.lookup("verb") == "restart") {
                return polkit.Result.YES;
            }
        }
    }
});
``` 