using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColorReplacerScript : MonoBehaviour
{
    public float hueSpeed = 0.2f;
    public float satSpeed = 0.1f;

    Material mat;

    void Start() {
        mat = GetComponent<SpriteRenderer>().material;
    }

    void Update() {
        Color destColor = Color.HSVToRGB(
            Time.time * hueSpeed % 1,
            1 - Mathf.PingPong(Time.time * satSpeed, 1),
            1);

        ChangeDestColor(destColor);
    }

    public void ChangeSrcColor(Color srcColor) {
        mat.SetColor("_SrcColor", srcColor);
    }

    public void ChangeDestColor(Color destColor) {
        mat.SetColor("_DestColor", destColor);
    }
}
