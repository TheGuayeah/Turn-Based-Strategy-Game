using UnityEngine;

public class UnitRagdoll : MonoBehaviour
{
   [SerializeField]
   private Transform rootBone;
   [SerializeField]
   private bool applyExplosion;

   public void Setup(Transform originalRootBone)
   {
      MatchAllBones(originalRootBone, rootBone);

      if (applyExplosion)
         ApplyExplosionToRagdoll(rootBone, 300f, transform.position, 10f);
   }

   private void MatchAllBones(Transform root, Transform clone)
   {
      foreach (Transform bone in root)
      {
         Transform cloneBone = clone.Find(bone.name);
         if (cloneBone != null)
         {
            cloneBone.position = bone.position;
            cloneBone.rotation = bone.rotation;

            MatchAllBones(bone, cloneBone);
         }
      }
   }

   private void ApplyExplosionToRagdoll(Transform root, float explosionForce, Vector3 explosionPosition, float explosionRadius)
   {
      foreach (Transform bone in root)
      {
         if (bone.TryGetComponent<Rigidbody>(out Rigidbody rigidBody))
         {
            rigidBody.AddExplosionForce(explosionForce, explosionPosition, explosionRadius);
         }

         ApplyExplosionToRagdoll(bone, explosionForce, explosionPosition, explosionRadius);
      }
   }
}
