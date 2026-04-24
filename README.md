# Exercise 1.1 — Terraform S3 Bucket

## Task 2 — Read the Plan

### Comando ejecutado

```
terraform plan
```

### Output completo

```
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.exercise will be created
  + resource "aws_s3_bucket" "exercise" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "oyd-exercise-bucket-2026"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)
      + grant (known after apply)
      + lifecycle_rule (known after apply)
      + logging (known after apply)
      + object_lock_configuration (known after apply)
      + replication_configuration (known after apply)
      + server_side_encryption_configuration (known after apply)
      + versioning (known after apply)
      + website (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

---

## Preguntas

### 1. ¿Cuántos recursos se crearán, cambiarán o destruirán?

**1 recurso se creará, 0 cambiarán y 0 se destruirán.**

El resumen al final del plan lo indica explícitamente:

```
Plan: 1 to add, 0 to change, 0 to destroy.
```

El único recurso es `aws_s3_bucket.exercise`, el bucket S3 definido en `main.tf`.

---

### 2. ¿Qué significa el símbolo `+` junto a cada atributo?

El símbolo `+` significa que ese atributo **será creado/añadido** como parte de un recurso nuevo. Dado que el bucket S3 no existe aún en AWS, Terraform debe crear el recurso completo desde cero, por lo que todos sus atributos llevan `+`.

En general, los símbolos del plan tienen este significado:

| Símbolo | Significado |
|---------|-------------|
| `+`     | El atributo (o recurso) será **creado** |
| `-`     | El atributo (o recurso) será **destruido** |
| `~`     | El atributo (o recurso) será **modificado en su lugar** |
| `-/+`   | El recurso será **destruido y recreado** |

---

### 3. Atributo marcado como `(known after apply)` — ¿por qué Terraform no puede conocer ese valor antes de aplicar?

**Atributo elegido:** `arn`

```
+ arn = (known after apply)
```

El ARN (Amazon Resource Name) es el identificador único global que AWS **asigna automáticamente** en el momento en que el recurso es creado en la nube. Terraform no puede calcular ni predecir ese valor de antemano porque:

1. **Lo genera AWS, no Terraform.** El ARN lo construye la API de AWS al recibir la solicitud de creación, incorporando la cuenta, la región y el nombre del bucket en tiempo real.
2. **Depende de datos de la sesión de creación.** Algunos valores (como el ID interno o la zona DNS) solo existen después de que la infraestructura ha sido provisionada.
3. **No está definido en el código.** El usuario únicamente especificó el nombre del bucket (`oyd-exercise-bucket-2026`); todo lo demás que AWS derive de esa creación es desconocido hasta el momento del `apply`.

Esto aplica de igual forma a otros atributos marcados como `(known after apply)` en el plan, como `id`, `region`, `bucket_domain_name`, `hosted_zone_id`, etc.

---

## Task 3 — Re-run the Plan (con tag `Owner` agregado)

> Se agregó el tag `Owner = "Estuardo Sabán | André Morales"` en `main.tf` antes de este segundo plan.

### Bloque diff `# aws_s3_bucket.exercise`

```
  # aws_s3_bucket.exercise will be created
  + resource "aws_s3_bucket" "exercise" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "oyd-exercise-bucket-2026"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Owner"       = "Estuardo Sabán | André Morales"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Owner"       = "Estuardo Sabán | André Morales"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)
      + grant (known after apply)
      + lifecycle_rule (known after apply)
      + logging (known after apply)
      + object_lock_configuration (known after apply)
      + replication_configuration (known after apply)
      + server_side_encryption_configuration (known after apply)
      + versioning (known after apply)
      + website (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

---

### Preguntas

#### 1. ¿Terraform propuso destruir y recrear el bucket, o actualizarlo en su lugar?

**Ninguna de las dos: propuso crearlo desde cero (`+ create`).**

Como nunca se ejecutó `terraform apply`, el bucket no existe ni en AWS ni en el state file de Terraform. Por eso el plan sigue mostrando `1 to add, 0 to change, 0 to destroy` — no hay nada que destruir ni actualizar.

Si el bucket ya existiera en el state y se le hubiera agregado únicamente el nuevo tag, Terraform habría propuesto una **actualización en su lugar** (`~`), porque los tags en S3 son un atributo mutable que AWS puede cambiar sin necesidad de recrear el recurso.

#### 2. ¿Por qué importa esa distinción?

La diferencia entre **actualizar en su lugar** (`~`) y **destruir y recrear** (`-/+`) tiene consecuencias críticas en producción:

| Comportamiento | Símbolo | Consecuencia |
|----------------|---------|--------------|
| Actualización en su lugar | `~` | El recurso sigue vivo; no hay interrupción de servicio ni pérdida de datos |
| Destruir y recrear | `-/+` | El recurso original se elimina antes de crear uno nuevo |

Cuando Terraform destruye y recrea un recurso:

- **Se pierde el ARN y el ID anterior.** Todo lo que referenciaba ese ARN (políticas IAM, CloudFront, otros recursos) queda roto.
- **Se pierden los datos.** En el caso de un bucket S3, si `force_destroy` no está habilitado la operación falla si el bucket tiene objetos; si está habilitado, los objetos se eliminan permanentemente.
- **Hay tiempo de inactividad.** Existe una ventana entre la destrucción y la recreación en la que el recurso no está disponible.

Algunos atributos en AWS son **inmutables**: cambiarlos obliga a Terraform a recrear el recurso (e.g., cambiar el nombre de un bucket S3, cambiar la región de un grupo de Auto Scaling). El plan siempre avisa con `-/+` cuando esto ocurre, por lo que **leer el plan antes de aplicar** es una práctica esencial para evitar pérdidas accidentales de datos.

---

## Task 4 — State file check

### Comando ejecutado

```
ls -la
```

### Output

```
total 834
drwxr-xr-x 1 Dell 197609      0 Apr 23 20:07 .
drwxr-xr-x 1 Dell 197609      0 Apr 23 19:49 ..
drwxr-xr-x 1 Dell 197609      0 Apr 23 19:42 .git
drwxr-xr-x 1 Dell 197609      0 Apr 23 19:58 .terraform
-rw-r--r-- 1 Dell 197609   1407 Apr 23 19:58 .terraform.lock.hcl
-rw-r--r-- 1 Dell 197609 711617 Apr 23 19:34 Exercise 1.1.docx
-rw-r--r-- 1 Dell 197609    199 Apr 23 20:05 main.tf
-rw-r--r-- 1 Dell 197609    194 Apr 23 19:57 provider.tf
-rw-r--r-- 1 Dell 197609   8264 Apr 23 20:07 README.md
-rw-r--r-- 1 Dell 197609  52903 Apr 23 19:59 terraform-init.png
-rw-r--r-- 1 Dell 197609  60559 Apr 23 20:01 terraform-plan.png
```

**No existe ningún archivo `terraform.tfstate` en el directorio.**

---

### Pregunta

#### 1. ¿Qué dice la ausencia del state file sobre la relación entre `plan` y `state`?

El state file (`terraform.tfstate`) es el registro que Terraform mantiene de los recursos que **ya fueron creados** mediante `terraform apply`. Su ausencia confirma dos cosas:

**`terraform plan` no crea ni requiere state.** El plan es una operación de solo lectura: Terraform compara el código fuente (`.tf`) con el state actual y con la API de AWS para calcular qué cambios serían necesarios. Si el state no existe, Terraform asume que ninguno de los recursos definidos existe todavía, y por eso el plan muestra `1 to add` en lugar de `0 to change`.

**El state solo se crea (o actualiza) al ejecutar `terraform apply`.** Hasta ese momento, por más veces que se corra `plan`, el directorio no tendrá `.tfstate`.

La relación entre los tres elementos es la siguiente:

```
Código (.tf)  ──┐
                ├──► terraform plan ──► diff (qué cambiaría)
State (.tfstate)─┘

Código (.tf)  ──┐
                ├──► terraform apply ──► cambios en AWS + state actualizado
State (.tfstate)─┘
```

En resumen: **`plan` lee el state; `apply` escribe el state.** Sin `apply` previo no hay state, y sin state Terraform trata todos los recursos definidos como nuevos.
