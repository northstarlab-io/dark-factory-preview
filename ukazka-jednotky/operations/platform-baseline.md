# Platform baseline - ukazka-jednotky

> Evidence toho, které platformní změny (osa A - agenti, normy, šablony) tahle STUDIO jednotka převzala. Odpovídá na otázku „na jaké verzi platformy běžím a co na mě čeká".
>
> **Zapisuje výhradně nástroj** `scaffold/validate.sh --baseline <jednotka> --accept <ID> --kdo "<jméno>"` po průchodu testem changesetu. Ruční editace je porušení disciplíny na úrovni ručního přepsání rendered artefaktu - evidence pak lže, že jsme synchronní. Legitimní východisko při neověřitelném testu je `--accept <ID> --force --duvod "<věta>"`, které zapíše řádek s viditelnou poznámkou.
>
> Tenhle soubor je **state** (per `scaffold/manifest.json`) - upgrade platformy se ho nikdy nedotkne. Šablona se do jednotky kopíruje jednou při scaffoldu a od té chvíle žije vlastním životem.
>
> Nezaměňovat s baseline osy B: nainstalovaný software si drží vlastní evidenci ve své instanci (JSON, čte ho server a sync skript). Jedna jednotka může nést obě zároveň.

**Jednotka:** ukazka-jednotky
**Platforma:** 2.14.0
**META commit:** n/a (ve vyděleném balíčku se otisk commitu zdrojového repa neuvádí)
**GLOBAL commit:** n/a (totéž)
**Poslední render:** n/a (jednotka nemá rendered artefakty)
**Převzato changesetů:** 0
**Poslední převzetí:** n/a

## Převzaté changesety

| ID | Datum převzetí | Kdo | Ověření |
|---|---|---|---|

## Rolling log

Historie převzetí, poznámky, vědomě odložené položky fronty. Header nahoře drží jen aktuální stav (distilát per OR-10), historie patří sem pod něj.

- 2026-08-09 - baseline založena při scaffoldu jednotky, fronta se počítá od nuly. Že je jednotka pozadu, není vada k omluvě: je to přesně ten stav, který má být vidět jako číslo.
