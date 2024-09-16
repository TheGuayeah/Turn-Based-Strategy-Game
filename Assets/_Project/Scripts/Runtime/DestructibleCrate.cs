using System;
using UnityEngine;
using Random = UnityEngine.Random;

public class DestructibleCrate : MonoBehaviour
{
   public static event EventHandler OnAnyCrateDestroyed;

   [SerializeField]
   private Transform crateDestroyedPrefab;

   private GridPosition gridPosition;

   private void Start()
   {
      gridPosition = LevelGrid.Instance.GetGridPosition(transform.position);
   }

   public GridPosition GetGridPosition()
   {
      return gridPosition;
   }

   public void Damage()
   {
      Transform crateDestroyed = Instantiate(
         crateDestroyedPrefab, 
         transform.position, 
         transform.rotation
      );

      float explosionForce = Random.Range(140f, 150f);
      float explosionRadius = Random.Range(8f, 10f);

      ApplyExplosionToParts(
         crateDestroyed,
         explosionForce,
         transform.position,
         explosionRadius
      );

      Destroy(gameObject);

      OnAnyCrateDestroyed?.Invoke(this, EventArgs.Empty);
   }

   private void ApplyExplosionToParts(Transform crate, float explosionForce, Vector3 explosionPosition, float explosionRadius)
   {
      foreach (Transform part in crate)
      {
         if (part.TryGetComponent<Rigidbody>(out Rigidbody rigidBody))
         {
            rigidBody.AddExplosionForce(explosionForce, explosionPosition, explosionRadius);
         }

         ApplyExplosionToParts(part, explosionForce, explosionPosition, explosionRadius);
      }
   }
}
