# Platform baseline - {{JEDNOTKA}}

> Evidence toho, které platformní změny (osa A - agenti, normy, šablony) tahle STUDIO jednotka převzala. Odpovídá na otázku „na jaké verzi platformy běžím a co na mě čeká".
>
> **Zapisuje výhradně nástroj** `scaffold/validate.sh --baseline <jednotka> --accept <ID> --kdo "<jméno>"` po průchodu testem changesetu. Ruční editace je porušení disciplíny na úrovni ručního přepsání rendered artefaktu - evidence pak lže, že jsme synchronní. Legitimní východisko při neověřitelném testu je `--accept <ID> --force --duvod "<věta>"`, které zapíše řádek s viditelnou poznámkou.
>
> Tenhle soubor je **state** (per `scaffold/manifest.json`) - upgrade platformy se ho nikdy nedotkne. Šablona se do jednotky kopíruje jednou při scaffoldu a od té chvíle žije vlastním životem.
>
> Nezaměňovat s baseline osy B: nainstalovaný software kokpitu si drží vlastní evidenci v `instance/cockpit-baseline.json` (JSON, čte ho server kokpitu a sync skript). Jedna jednotka může nést obě zároveň.

**Jednotka:** {{JEDNOTKA}}
**Platforma:** {{VERZE}}
**META commit:** {{SHA}} ({{DATUM}})
**GLOBAL commit:** {{SHA}} ({{DATUM}})
**Poslední render:** {{DATUM}}, platforma {{VERZE}} (nebo `n/a`, pokud jednotka nemá rendered artefakty)
**Převzato changesetů:** 0
**Poslední převzetí:** {{DATUM}}, {{ID_CHANGESETU}}

## Převzaté changesety

| ID | Datum převzetí | Kdo | Ověření |
|---|---|---|---|
| {{ID_CHANGESETU}} | {{DATUM}} | {{KDO}} | {{N}} testů PASS |

## Rolling log

Historie převzetí, poznámky, vědomě odložené položky fronty. Header nahoře drží jen aktuální stav (distilát per OR-10), historie patří sem pod něj.

- {{DATUM}} - baseline založena při scaffoldu jednotky, fronta se počítá od nuly.
