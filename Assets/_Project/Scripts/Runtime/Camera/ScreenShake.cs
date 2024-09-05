using Cinemachine;
using UnityEngine;

public class ScreenShake : Singleton<ScreenShake>
{
   private CinemachineImpulseSource impulseSource;

   protected override void Awake()
   {
      base.Awake();
      impulseSource = GetComponent<CinemachineImpulseSource>();
   }

   public void Shake(float instensity = 1f)
   {
      impulseSource.GenerateImpulse(instensity);
   }
}
