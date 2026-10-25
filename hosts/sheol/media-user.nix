{ _ }:

# Owner of the shared media files under /mnt/moriyya/media (the dataset the k3s media apps mount
# as /data, plus each app's config directory). The same numbers are used as PUID/PGID in
# k3s-collective (apps/media/*), so they must match there. A dedicated account keeps the apps off
# the human login's uid 1000 (boog): a compromised app then cannot touch anything boog owns.
# No login, no home, no shell.
{
  users.groups.media.gid = 1500;

  users.users.media = {
    isSystemUser = true;
    uid = 1500;
    group = "media";
    description = "Owner of the shared media files";
  };
}
