using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HueReplacerScript : MonoBehaviour
{
    public float hueSpeed = 0.2f;

    Material mat;

    void Start() {
        mat = GetComponent<SpriteRenderer>().material;
    }

    void Update() {
        mat.SetColor("_DestHueColor", Color.HSVToRGB(Time.time * hueSpeed % 1, 1, 1));
    }
}
