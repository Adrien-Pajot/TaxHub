-- suppresion de la colonne id_liste de la table vm_taxref_for_autocomplete
-- la table devient une vue matérialisée et contient une seule fois tout taxref

-- Creation d'une vue matérialis&ée de tous les noms de Taxref mis en forme pour la recherche de taxons
DROP TABLE IF EXISTS taxonomie.vm_taxref_list_forautocomplete;
DROP MATERIALIZED VIEW IF EXISTS taxonomie.vm_taxref_list_forautocomplete;
DROP SEQUENCE IF EXISTS vm_taxref_list_forautocomplete_id_seq;
CREATE SEQUENCE vm_taxref_list_forautocomplete_id_seq;

CREATE MATERIALIZED VIEW taxonomie.vm_taxref_list_forautocomplete AS
SELECT 
  t.gid,
  t.cd_nom,
  t.cd_ref,
  t.search_name,
  t.nom_valide,
  t.lb_nom,
  t.regne,
  t.group2_inpn
FROM (
  -- PARTIE NOM SCIENTIFIQUE : ici on prend TOUS les synonymes.
  SELECT 
    nextval('vm_taxref_list_forautocomplete_id_seq') as gid,
    t_1.cd_nom,
    t_1.cd_ref,
    concat(t_1.lb_nom, ' =  <i> ', t_1.nom_valide, '</i>', ' - [', t_1.id_rang, ' - ', t_1.cd_nom , ']') AS search_name,
    t_1.nom_valide,
    t_1.lb_nom,
    t_1.regne,
    t_1.group2_inpn
  FROM taxonomie.taxref t_1
  UNION
  -- PARTIE NOM FRANCAIS : ici on prend une seule fois (DISTINCT) dans Taxref tous les taxons de références 
  -- On ne prend pas les taxons qui n'ont pas de nom vern dans taxref,
  -- donc si un taxon n'a pas de nom vern dans Taxref, il n'est accessible que par son nom scientifique.
  SELECT DISTINCT 
    nextval('vm_taxref_list_forautocomplete_id_seq') as gid,
    t_1.cd_nom,
    t_1.cd_ref,
    concat(split_part(t_1.nom_vern, ',', 1), ' =  <i> ', t_1.nom_valide, '</i>', ' - [', t_1.id_rang, ' - ', t_1.cd_ref , ']' ) AS search_name,
    t_1.nom_valide,
    t_1.lb_nom,
    t_1.regne,
    t_1.group2_inpn
  FROM taxonomie.taxref t_1 
  WHERE t_1.nom_vern IS NOT null and t_1.cd_nom = t_1.cd_ref
) t;
COMMENT ON MATERIALIZED VIEW taxonomie.vm_taxref_list_forautocomplete
    IS 'Vue matérialisée permettant de faire des autocomplete construite à partir d''une requete sur tout taxref.';

-- Creation des index de la table vm_taxref_list_forautocomplete
CREATE unique index i_vm_taxref_list_forautocomplete_gid 
  ON taxonomie.vm_taxref_list_forautocomplete (gid);
CREATE INDEX i_vm_taxref_list_forautocomplete_cd_nom
  ON vm_taxref_list_forautocomplete (cd_nom ASC NULLS LAST);
CREATE INDEX i_vm_taxref_list_forautocomplete_search_name
  ON vm_taxref_list_forautocomplete (search_name ASC NULLS LAST);
CREATE INDEX i_tri_vm_taxref_list_forautocomplete_search_name
  ON vm_taxref_list_forautocomplete
  USING gist
  (search_name  gist_trgm_ops);

-- suppression des triggers qui alimentaient cette table
 DROP TRIGGER trg_refresh_mv_taxref_list_forautocomplete ON taxonomie.cor_nom_liste;
 DROP TRIGGER trg_refresh_nomfrancais_mv_taxref_list_forautocomplete ON taxonomie.bib_noms;

-- et des fonctions triggers
DROP FUNCTION taxonomie.trg_fct_refresh_nomfrancais_mv_taxref_list_forautocomplete;
DROP FUNCTION taxonomie.trg_fct_refresh_mv_taxref_list_forautocomplete;