using System;
using UnityEngine;

public class ScreenShakeActions : MonoBehaviour
{
   private void Start()
   {
      ShootAction.OnAnyShoot += ShootAction_OnAnyShoot;
      SwordAction.OnAnySwordHit += SwordAction_OnAnySwordHit;
      GrenadeProjectile.OnAnyGrenadeExploded += GrenadeProjectile_OnAnyGrenadeExploded;
   }

   private void ShootAction_OnAnyShoot(object sender, ShootAction.OnShootEventArgs e)
   {
      ScreenShake.Instance.Shake();
   }

   private void SwordAction_OnAnySwordHit(object sender, EventArgs e)
   {
      ScreenShake.Instance.Shake(2f);
   }

   private void GrenadeProjectile_OnAnyGrenadeExploded(object sender, EventArgs e)
   {
      ScreenShake.Instance.Shake(5f);
   }
}
