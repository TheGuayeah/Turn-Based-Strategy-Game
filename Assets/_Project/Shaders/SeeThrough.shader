Shader "Custom/See Through URP"
{
    Properties
    {
        _BaseColor("BaseColor", Color) = (1, 0.7921569, 0, 1)
        [NoScaleOffset]_Grid("Grid", 2D) = "white" {}
        OverlayAmount("OverlayAmount", Range(0, 1)) = 0.5
        _GridScale("GridScale", Float) = 1
        _Falloff("Falloff", Float) = 50
        _Offset("Offset", Vector) = (0, 0, 0, 0)
        _Tiling("Tiling", Vector) = (1, 1, 0, 0)
        _TargetPos("Target Position", Vector) = (0.5, 0.5, 0, 0)
        _Size("Size", Float) = 1
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        _Opacity("Opacity", Range(0, 1)) = 1
        [NonModifiableTextureData][NoScaleOffset]_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D("Texture2D", 2D) = "white" {}
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        #define _ALPHATEST_ON 1
        #define _SPECULAR_SETUP 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D_TexelSize;
        float4 _Grid_TexelSize;
        float OverlayAmount;
        float _GridScale;
        float2 _Tiling;
        float2 _Offset;
        float _Falloff;
        float4 _BaseColor;
        float2 _TargetPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D);
        TEXTURE2D(_Grid);
        SAMPLER(sampler_Grid);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_32acbc737c5148f6b02a278b3024364e_Out_0_Vector4 = _BaseColor;
            float4 Color_3ca898713668c983b29c8ff63f7d33c3 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
            UnityTexture2D _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Grid);
            float3 _Vector3_e3bd3c2ab75942c5825bb898c3071ab9_Out_0_Vector3 = float3(1, 0, 1);
            float3 _Add_f8e254be01f545ffa9d5fe38a24f10fb_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Vector3_e3bd3c2ab75942c5825bb898c3071ab9_Out_0_Vector3, _Add_f8e254be01f545ffa9d5fe38a24f10fb_Out_2_Vector3);
            float _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float = _GridScale;
            float _Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float = _Falloff;
            float3 Triplanar_c1699351edff078e9f052737bbebcedb_UV = _Add_f8e254be01f545ffa9d5fe38a24f10fb_Out_2_Vector3 * _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float;
            float3 Triplanar_c1699351edff078e9f052737bbebcedb_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_c1699351edff078e9f052737bbebcedb_Blend /= dot(Triplanar_c1699351edff078e9f052737bbebcedb_Blend, 1.0);
            float4 Triplanar_c1699351edff078e9f052737bbebcedb_X = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.zy);
            float4 Triplanar_c1699351edff078e9f052737bbebcedb_Y = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xz);
            float4 Triplanar_c1699351edff078e9f052737bbebcedb_Z = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xy);
            float4 _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4 = Triplanar_c1699351edff078e9f052737bbebcedb_X * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.x + Triplanar_c1699351edff078e9f052737bbebcedb_Y * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.y + Triplanar_c1699351edff078e9f052737bbebcedb_Z * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.z;
            float _Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float = OverlayAmount;
            float4 _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4;
            Unity_Lerp_float4(Color_3ca898713668c983b29c8ff63f7d33c3, _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4, (_Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float.xxxx), _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4);
            float4 _Multiply_58be9a53fd903b8e990da8a3efb58f3f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_32acbc737c5148f6b02a278b3024364e_Out_0_Vector4, _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4, _Multiply_58be9a53fd903b8e990da8a3efb58f3f_Out_2_Vector4);
            float2 _Property_1c3ef19df37d435097bc1036819fbc2b_Out_0_Vector2 = _Tiling;
            float2 _Property_262e801cc00441f0b9d8e757d91c736a_Out_0_Vector2 = _Offset;
            float2 _TilingAndOffset_bcc14c74b53f466f86c1ffa9f287b64f_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_1c3ef19df37d435097bc1036819fbc2b_Out_0_Vector2, _Property_262e801cc00441f0b9d8e757d91c736a_Out_0_Vector2, _TilingAndOffset_bcc14c74b53f466f86c1ffa9f287b64f_Out_3_Vector2);
            float4 _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_bcc14c74b53f466f86c1ffa9f287b64f_Out_3_Vector2) );
            float _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_R_4_Float = _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4.r;
            float _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_G_5_Float = _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4.g;
            float _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_B_6_Float = _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4.b;
            float _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_A_7_Float = _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4.a;
            float4 _Multiply_d254ce4564e841a499d7e53f5ea86610_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_58be9a53fd903b8e990da8a3efb58f3f_Out_2_Vector4, _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4, _Multiply_d254ce4564e841a499d7e53f5ea86610_Out_2_Vector4);
            float _Property_6fc1cf12c45b463db43c22b144dc9fbe_Out_0_Float = _Opacity;
            float _Property_503974d382d54d43931e6fba219b7c91_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_89055baebdbe4acf8fc1418f372c07ac_Out_0_Vector2 = _TargetPos;
            float2 _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2;
            Unity_Remap_float2(_Property_89055baebdbe4acf8fc1418f372c07ac_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2);
            float2 _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4.xy), _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2, _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2);
            float2 _TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4.xy), float2 (1, 1), _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2, _TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2);
            float2 _Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2, float2(2, 2), _Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2);
            float2 _Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2, float2(1, 1), _Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2);
            float _Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float = _Size;
            float _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float);
            float _Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float;
            Unity_Multiply_float_float(_Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float, _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float, _Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float);
            float2 _Vector2_a56798a6189b4c37ac30566894b1b8aa_Out_0_Vector2 = float2(_Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float, _Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float);
            float2 _Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2, _Vector2_a56798a6189b4c37ac30566894b1b8aa_Out_0_Vector2, _Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2);
            float _Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float;
            Unity_Length_float2(_Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2, _Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float);
            float _OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float;
            Unity_OneMinus_float(_Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float, _OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float);
            float _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float;
            Unity_Saturate_float(_OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float, _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float);
            float _Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float;
            Unity_Smoothstep_float(0, _Property_503974d382d54d43931e6fba219b7c91_Out_0_Float, _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float, _Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float);
            float _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 50, _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float);
            float _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float, _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float, _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float);
            float _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float;
            Unity_Add_float(_Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float, _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float, _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float);
            float _Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float;
            Unity_Multiply_float_float(_Property_6fc1cf12c45b463db43c22b144dc9fbe_Out_0_Float, _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float, _Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float);
            float _Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float;
            Unity_Clamp_float(_Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float, 0, 1, _Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float);
            float _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float;
            Unity_OneMinus_float(_Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float, _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float);
            surface.BaseColor = (_Multiply_d254ce4564e841a499d7e53f5ea86610_Out_2_Vector4.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        #define _ALPHATEST_ON 1
        #define _SPECULAR_SETUP 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D_TexelSize;
        float4 _Grid_TexelSize;
        float OverlayAmount;
        float _GridScale;
        float2 _Tiling;
        float2 _Offset;
        float _Falloff;
        float4 _BaseColor;
        float2 _TargetPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D);
        TEXTURE2D(_Grid);
        SAMPLER(sampler_Grid);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_32acbc737c5148f6b02a278b3024364e_Out_0_Vector4 = _BaseColor;
            float4 Color_3ca898713668c983b29c8ff63f7d33c3 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
            UnityTexture2D _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Grid);
            float3 _Vector3_e3bd3c2ab75942c5825bb898c3071ab9_Out_0_Vector3 = float3(1, 0, 1);
            float3 _Add_f8e254be01f545ffa9d5fe38a24f10fb_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Vector3_e3bd3c2ab75942c5825bb898c3071ab9_Out_0_Vector3, _Add_f8e254be01f545ffa9d5fe38a24f10fb_Out_2_Vector3);
            float _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float = _GridScale;
            float _Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float = _Falloff;
            float3 Triplanar_c1699351edff078e9f052737bbebcedb_UV = _Add_f8e254be01f545ffa9d5fe38a24f10fb_Out_2_Vector3 * _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float;
            float3 Triplanar_c1699351edff078e9f052737bbebcedb_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_c1699351edff078e9f052737bbebcedb_Blend /= dot(Triplanar_c1699351edff078e9f052737bbebcedb_Blend, 1.0);
            float4 Triplanar_c1699351edff078e9f052737bbebcedb_X = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.zy);
            float4 Triplanar_c1699351edff078e9f052737bbebcedb_Y = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xz);
            float4 Triplanar_c1699351edff078e9f052737bbebcedb_Z = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xy);
            float4 _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4 = Triplanar_c1699351edff078e9f052737bbebcedb_X * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.x + Triplanar_c1699351edff078e9f052737bbebcedb_Y * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.y + Triplanar_c1699351edff078e9f052737bbebcedb_Z * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.z;
            float _Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float = OverlayAmount;
            float4 _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4;
            Unity_Lerp_float4(Color_3ca898713668c983b29c8ff63f7d33c3, _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4, (_Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float.xxxx), _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4);
            float4 _Multiply_58be9a53fd903b8e990da8a3efb58f3f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_32acbc737c5148f6b02a278b3024364e_Out_0_Vector4, _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4, _Multiply_58be9a53fd903b8e990da8a3efb58f3f_Out_2_Vector4);
            float2 _Property_1c3ef19df37d435097bc1036819fbc2b_Out_0_Vector2 = _Tiling;
            float2 _Property_262e801cc00441f0b9d8e757d91c736a_Out_0_Vector2 = _Offset;
            float2 _TilingAndOffset_bcc14c74b53f466f86c1ffa9f287b64f_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_1c3ef19df37d435097bc1036819fbc2b_Out_0_Vector2, _Property_262e801cc00441f0b9d8e757d91c736a_Out_0_Vector2, _TilingAndOffset_bcc14c74b53f466f86c1ffa9f287b64f_Out_3_Vector2);
            float4 _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_bcc14c74b53f466f86c1ffa9f287b64f_Out_3_Vector2) );
            float _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_R_4_Float = _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4.r;
            float _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_G_5_Float = _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4.g;
            float _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_B_6_Float = _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4.b;
            float _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_A_7_Float = _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4.a;
            float4 _Multiply_d254ce4564e841a499d7e53f5ea86610_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_58be9a53fd903b8e990da8a3efb58f3f_Out_2_Vector4, _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4, _Multiply_d254ce4564e841a499d7e53f5ea86610_Out_2_Vector4);
            float _Property_6fc1cf12c45b463db43c22b144dc9fbe_Out_0_Float = _Opacity;
            float _Property_503974d382d54d43931e6fba219b7c91_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_89055baebdbe4acf8fc1418f372c07ac_Out_0_Vector2 = _TargetPos;
            float2 _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2;
            Unity_Remap_float2(_Property_89055baebdbe4acf8fc1418f372c07ac_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2);
            float2 _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4.xy), _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2, _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2);
            float2 _TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4.xy), float2 (1, 1), _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2, _TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2);
            float2 _Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2, float2(2, 2), _Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2);
            float2 _Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2, float2(1, 1), _Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2);
            float _Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float = _Size;
            float _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float);
            float _Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float;
            Unity_Multiply_float_float(_Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float, _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float, _Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float);
            float2 _Vector2_a56798a6189b4c37ac30566894b1b8aa_Out_0_Vector2 = float2(_Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float, _Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float);
            float2 _Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2, _Vector2_a56798a6189b4c37ac30566894b1b8aa_Out_0_Vector2, _Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2);
            float _Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float;
            Unity_Length_float2(_Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2, _Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float);
            float _OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float;
            Unity_OneMinus_float(_Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float, _OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float);
            float _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float;
            Unity_Saturate_float(_OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float, _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float);
            float _Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float;
            Unity_Smoothstep_float(0, _Property_503974d382d54d43931e6fba219b7c91_Out_0_Float, _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float, _Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float);
            float _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 50, _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float);
            float _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float, _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float, _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float);
            float _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float;
            Unity_Add_float(_Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float, _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float, _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float);
            float _Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float;
            Unity_Multiply_float_float(_Property_6fc1cf12c45b463db43c22b144dc9fbe_Out_0_Float, _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float, _Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float);
            float _Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float;
            Unity_Clamp_float(_Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float, 0, 1, _Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float);
            float _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float;
            Unity_OneMinus_float(_Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float, _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float);
            surface.BaseColor = (_Multiply_d254ce4564e841a499d7e53f5ea86610_Out_2_Vector4.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D_TexelSize;
        float4 _Grid_TexelSize;
        float OverlayAmount;
        float _GridScale;
        float2 _Tiling;
        float2 _Offset;
        float _Falloff;
        float4 _BaseColor;
        float2 _TargetPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D);
        TEXTURE2D(_Grid);
        SAMPLER(sampler_Grid);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_6fc1cf12c45b463db43c22b144dc9fbe_Out_0_Float = _Opacity;
            float _Property_503974d382d54d43931e6fba219b7c91_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_89055baebdbe4acf8fc1418f372c07ac_Out_0_Vector2 = _TargetPos;
            float2 _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2;
            Unity_Remap_float2(_Property_89055baebdbe4acf8fc1418f372c07ac_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2);
            float2 _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4.xy), _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2, _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2);
            float2 _TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4.xy), float2 (1, 1), _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2, _TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2);
            float2 _Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2, float2(2, 2), _Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2);
            float2 _Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2, float2(1, 1), _Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2);
            float _Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float = _Size;
            float _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float);
            float _Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float;
            Unity_Multiply_float_float(_Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float, _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float, _Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float);
            float2 _Vector2_a56798a6189b4c37ac30566894b1b8aa_Out_0_Vector2 = float2(_Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float, _Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float);
            float2 _Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2, _Vector2_a56798a6189b4c37ac30566894b1b8aa_Out_0_Vector2, _Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2);
            float _Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float;
            Unity_Length_float2(_Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2, _Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float);
            float _OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float;
            Unity_OneMinus_float(_Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float, _OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float);
            float _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float;
            Unity_Saturate_float(_OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float, _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float);
            float _Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float;
            Unity_Smoothstep_float(0, _Property_503974d382d54d43931e6fba219b7c91_Out_0_Float, _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float, _Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float);
            float _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 50, _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float);
            float _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float, _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float, _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float);
            float _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float;
            Unity_Add_float(_Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float, _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float, _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float);
            float _Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float;
            Unity_Multiply_float_float(_Property_6fc1cf12c45b463db43c22b144dc9fbe_Out_0_Float, _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float, _Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float);
            float _Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float;
            Unity_Clamp_float(_Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float, 0, 1, _Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float);
            float _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float;
            Unity_OneMinus_float(_Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float, _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float);
            surface.Alpha = _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float3 normalWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D_TexelSize;
        float4 _Grid_TexelSize;
        float OverlayAmount;
        float _GridScale;
        float2 _Tiling;
        float2 _Offset;
        float _Falloff;
        float4 _BaseColor;
        float2 _TargetPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D);
        TEXTURE2D(_Grid);
        SAMPLER(sampler_Grid);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_6fc1cf12c45b463db43c22b144dc9fbe_Out_0_Float = _Opacity;
            float _Property_503974d382d54d43931e6fba219b7c91_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_89055baebdbe4acf8fc1418f372c07ac_Out_0_Vector2 = _TargetPos;
            float2 _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2;
            Unity_Remap_float2(_Property_89055baebdbe4acf8fc1418f372c07ac_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2);
            float2 _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4.xy), _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2, _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2);
            float2 _TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4.xy), float2 (1, 1), _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2, _TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2);
            float2 _Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2, float2(2, 2), _Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2);
            float2 _Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2, float2(1, 1), _Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2);
            float _Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float = _Size;
            float _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float);
            float _Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float;
            Unity_Multiply_float_float(_Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float, _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float, _Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float);
            float2 _Vector2_a56798a6189b4c37ac30566894b1b8aa_Out_0_Vector2 = float2(_Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float, _Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float);
            float2 _Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2, _Vector2_a56798a6189b4c37ac30566894b1b8aa_Out_0_Vector2, _Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2);
            float _Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float;
            Unity_Length_float2(_Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2, _Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float);
            float _OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float;
            Unity_OneMinus_float(_Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float, _OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float);
            float _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float;
            Unity_Saturate_float(_OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float, _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float);
            float _Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float;
            Unity_Smoothstep_float(0, _Property_503974d382d54d43931e6fba219b7c91_Out_0_Float, _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float, _Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float);
            float _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 50, _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float);
            float _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float, _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float, _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float);
            float _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float;
            Unity_Add_float(_Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float, _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float, _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float);
            float _Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float;
            Unity_Multiply_float_float(_Property_6fc1cf12c45b463db43c22b144dc9fbe_Out_0_Float, _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float, _Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float);
            float _Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float;
            Unity_Clamp_float(_Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float, 0, 1, _Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float);
            float _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float;
            Unity_OneMinus_float(_Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float, _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
             float3 positionWS : INTERP3;
             float3 normalWS : INTERP4;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D_TexelSize;
        float4 _Grid_TexelSize;
        float OverlayAmount;
        float _GridScale;
        float2 _Tiling;
        float2 _Offset;
        float _Falloff;
        float4 _BaseColor;
        float2 _TargetPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D);
        TEXTURE2D(_Grid);
        SAMPLER(sampler_Grid);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_32acbc737c5148f6b02a278b3024364e_Out_0_Vector4 = _BaseColor;
            float4 Color_3ca898713668c983b29c8ff63f7d33c3 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
            UnityTexture2D _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Grid);
            float3 _Vector3_e3bd3c2ab75942c5825bb898c3071ab9_Out_0_Vector3 = float3(1, 0, 1);
            float3 _Add_f8e254be01f545ffa9d5fe38a24f10fb_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Vector3_e3bd3c2ab75942c5825bb898c3071ab9_Out_0_Vector3, _Add_f8e254be01f545ffa9d5fe38a24f10fb_Out_2_Vector3);
            float _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float = _GridScale;
            float _Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float = _Falloff;
            float3 Triplanar_c1699351edff078e9f052737bbebcedb_UV = _Add_f8e254be01f545ffa9d5fe38a24f10fb_Out_2_Vector3 * _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float;
            float3 Triplanar_c1699351edff078e9f052737bbebcedb_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_c1699351edff078e9f052737bbebcedb_Blend /= dot(Triplanar_c1699351edff078e9f052737bbebcedb_Blend, 1.0);
            float4 Triplanar_c1699351edff078e9f052737bbebcedb_X = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.zy);
            float4 Triplanar_c1699351edff078e9f052737bbebcedb_Y = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xz);
            float4 Triplanar_c1699351edff078e9f052737bbebcedb_Z = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xy);
            float4 _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4 = Triplanar_c1699351edff078e9f052737bbebcedb_X * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.x + Triplanar_c1699351edff078e9f052737bbebcedb_Y * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.y + Triplanar_c1699351edff078e9f052737bbebcedb_Z * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.z;
            float _Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float = OverlayAmount;
            float4 _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4;
            Unity_Lerp_float4(Color_3ca898713668c983b29c8ff63f7d33c3, _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4, (_Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float.xxxx), _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4);
            float4 _Multiply_58be9a53fd903b8e990da8a3efb58f3f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_32acbc737c5148f6b02a278b3024364e_Out_0_Vector4, _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4, _Multiply_58be9a53fd903b8e990da8a3efb58f3f_Out_2_Vector4);
            float2 _Property_1c3ef19df37d435097bc1036819fbc2b_Out_0_Vector2 = _Tiling;
            float2 _Property_262e801cc00441f0b9d8e757d91c736a_Out_0_Vector2 = _Offset;
            float2 _TilingAndOffset_bcc14c74b53f466f86c1ffa9f287b64f_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_1c3ef19df37d435097bc1036819fbc2b_Out_0_Vector2, _Property_262e801cc00441f0b9d8e757d91c736a_Out_0_Vector2, _TilingAndOffset_bcc14c74b53f466f86c1ffa9f287b64f_Out_3_Vector2);
            float4 _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_bcc14c74b53f466f86c1ffa9f287b64f_Out_3_Vector2) );
            float _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_R_4_Float = _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4.r;
            float _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_G_5_Float = _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4.g;
            float _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_B_6_Float = _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4.b;
            float _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_A_7_Float = _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4.a;
            float4 _Multiply_d254ce4564e841a499d7e53f5ea86610_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_58be9a53fd903b8e990da8a3efb58f3f_Out_2_Vector4, _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4, _Multiply_d254ce4564e841a499d7e53f5ea86610_Out_2_Vector4);
            float _Property_6fc1cf12c45b463db43c22b144dc9fbe_Out_0_Float = _Opacity;
            float _Property_503974d382d54d43931e6fba219b7c91_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_89055baebdbe4acf8fc1418f372c07ac_Out_0_Vector2 = _TargetPos;
            float2 _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2;
            Unity_Remap_float2(_Property_89055baebdbe4acf8fc1418f372c07ac_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2);
            float2 _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4.xy), _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2, _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2);
            float2 _TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4.xy), float2 (1, 1), _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2, _TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2);
            float2 _Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2, float2(2, 2), _Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2);
            float2 _Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2, float2(1, 1), _Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2);
            float _Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float = _Size;
            float _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float);
            float _Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float;
            Unity_Multiply_float_float(_Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float, _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float, _Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float);
            float2 _Vector2_a56798a6189b4c37ac30566894b1b8aa_Out_0_Vector2 = float2(_Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float, _Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float);
            float2 _Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2, _Vector2_a56798a6189b4c37ac30566894b1b8aa_Out_0_Vector2, _Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2);
            float _Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float;
            Unity_Length_float2(_Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2, _Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float);
            float _OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float;
            Unity_OneMinus_float(_Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float, _OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float);
            float _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float;
            Unity_Saturate_float(_OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float, _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float);
            float _Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float;
            Unity_Smoothstep_float(0, _Property_503974d382d54d43931e6fba219b7c91_Out_0_Float, _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float, _Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float);
            float _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 50, _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float);
            float _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float, _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float, _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float);
            float _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float;
            Unity_Add_float(_Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float, _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float, _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float);
            float _Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float;
            Unity_Multiply_float_float(_Property_6fc1cf12c45b463db43c22b144dc9fbe_Out_0_Float, _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float, _Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float);
            float _Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float;
            Unity_Clamp_float(_Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float, 0, 1, _Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float);
            float _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float;
            Unity_OneMinus_float(_Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float, _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float);
            surface.BaseColor = (_Multiply_d254ce4564e841a499d7e53f5ea86610_Out_2_Vector4.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D_TexelSize;
        float4 _Grid_TexelSize;
        float OverlayAmount;
        float _GridScale;
        float2 _Tiling;
        float2 _Offset;
        float _Falloff;
        float4 _BaseColor;
        float2 _TargetPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D);
        TEXTURE2D(_Grid);
        SAMPLER(sampler_Grid);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_6fc1cf12c45b463db43c22b144dc9fbe_Out_0_Float = _Opacity;
            float _Property_503974d382d54d43931e6fba219b7c91_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_89055baebdbe4acf8fc1418f372c07ac_Out_0_Vector2 = _TargetPos;
            float2 _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2;
            Unity_Remap_float2(_Property_89055baebdbe4acf8fc1418f372c07ac_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2);
            float2 _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4.xy), _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2, _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2);
            float2 _TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4.xy), float2 (1, 1), _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2, _TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2);
            float2 _Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2, float2(2, 2), _Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2);
            float2 _Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2, float2(1, 1), _Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2);
            float _Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float = _Size;
            float _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float);
            float _Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float;
            Unity_Multiply_float_float(_Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float, _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float, _Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float);
            float2 _Vector2_a56798a6189b4c37ac30566894b1b8aa_Out_0_Vector2 = float2(_Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float, _Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float);
            float2 _Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2, _Vector2_a56798a6189b4c37ac30566894b1b8aa_Out_0_Vector2, _Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2);
            float _Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float;
            Unity_Length_float2(_Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2, _Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float);
            float _OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float;
            Unity_OneMinus_float(_Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float, _OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float);
            float _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float;
            Unity_Saturate_float(_OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float, _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float);
            float _Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float;
            Unity_Smoothstep_float(0, _Property_503974d382d54d43931e6fba219b7c91_Out_0_Float, _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float, _Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float);
            float _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 50, _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float);
            float _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float, _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float, _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float);
            float _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float;
            Unity_Add_float(_Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float, _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float, _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float);
            float _Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float;
            Unity_Multiply_float_float(_Property_6fc1cf12c45b463db43c22b144dc9fbe_Out_0_Float, _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float, _Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float);
            float _Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float;
            Unity_Clamp_float(_Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float, 0, 1, _Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float);
            float _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float;
            Unity_OneMinus_float(_Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float, _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float);
            surface.Alpha = _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D_TexelSize;
        float4 _Grid_TexelSize;
        float OverlayAmount;
        float _GridScale;
        float2 _Tiling;
        float2 _Offset;
        float _Falloff;
        float4 _BaseColor;
        float2 _TargetPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D);
        TEXTURE2D(_Grid);
        SAMPLER(sampler_Grid);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_6fc1cf12c45b463db43c22b144dc9fbe_Out_0_Float = _Opacity;
            float _Property_503974d382d54d43931e6fba219b7c91_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_89055baebdbe4acf8fc1418f372c07ac_Out_0_Vector2 = _TargetPos;
            float2 _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2;
            Unity_Remap_float2(_Property_89055baebdbe4acf8fc1418f372c07ac_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2);
            float2 _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4.xy), _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2, _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2);
            float2 _TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4.xy), float2 (1, 1), _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2, _TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2);
            float2 _Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2, float2(2, 2), _Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2);
            float2 _Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2, float2(1, 1), _Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2);
            float _Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float = _Size;
            float _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float);
            float _Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float;
            Unity_Multiply_float_float(_Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float, _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float, _Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float);
            float2 _Vector2_a56798a6189b4c37ac30566894b1b8aa_Out_0_Vector2 = float2(_Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float, _Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float);
            float2 _Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2, _Vector2_a56798a6189b4c37ac30566894b1b8aa_Out_0_Vector2, _Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2);
            float _Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float;
            Unity_Length_float2(_Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2, _Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float);
            float _OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float;
            Unity_OneMinus_float(_Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float, _OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float);
            float _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float;
            Unity_Saturate_float(_OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float, _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float);
            float _Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float;
            Unity_Smoothstep_float(0, _Property_503974d382d54d43931e6fba219b7c91_Out_0_Float, _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float, _Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float);
            float _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 50, _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float);
            float _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float, _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float, _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float);
            float _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float;
            Unity_Add_float(_Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float, _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float, _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float);
            float _Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float;
            Unity_Multiply_float_float(_Property_6fc1cf12c45b463db43c22b144dc9fbe_Out_0_Float, _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float, _Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float);
            float _Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float;
            Unity_Clamp_float(_Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float, 0, 1, _Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float);
            float _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float;
            Unity_OneMinus_float(_Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float, _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float);
            surface.Alpha = _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 AbsoluteWorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
             float3 normalWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D_TexelSize;
        float4 _Grid_TexelSize;
        float OverlayAmount;
        float _GridScale;
        float2 _Tiling;
        float2 _Offset;
        float _Falloff;
        float4 _BaseColor;
        float2 _TargetPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D);
        TEXTURE2D(_Grid);
        SAMPLER(sampler_Grid);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_32acbc737c5148f6b02a278b3024364e_Out_0_Vector4 = _BaseColor;
            float4 Color_3ca898713668c983b29c8ff63f7d33c3 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
            UnityTexture2D _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Grid);
            float3 _Vector3_e3bd3c2ab75942c5825bb898c3071ab9_Out_0_Vector3 = float3(1, 0, 1);
            float3 _Add_f8e254be01f545ffa9d5fe38a24f10fb_Out_2_Vector3;
            Unity_Add_float3(IN.AbsoluteWorldSpacePosition, _Vector3_e3bd3c2ab75942c5825bb898c3071ab9_Out_0_Vector3, _Add_f8e254be01f545ffa9d5fe38a24f10fb_Out_2_Vector3);
            float _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float = _GridScale;
            float _Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float = _Falloff;
            float3 Triplanar_c1699351edff078e9f052737bbebcedb_UV = _Add_f8e254be01f545ffa9d5fe38a24f10fb_Out_2_Vector3 * _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float;
            float3 Triplanar_c1699351edff078e9f052737bbebcedb_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float, floor(log2(Min_float())/log2(1/sqrt(3)))) );
            Triplanar_c1699351edff078e9f052737bbebcedb_Blend /= dot(Triplanar_c1699351edff078e9f052737bbebcedb_Blend, 1.0);
            float4 Triplanar_c1699351edff078e9f052737bbebcedb_X = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.zy);
            float4 Triplanar_c1699351edff078e9f052737bbebcedb_Y = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xz);
            float4 Triplanar_c1699351edff078e9f052737bbebcedb_Z = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xy);
            float4 _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4 = Triplanar_c1699351edff078e9f052737bbebcedb_X * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.x + Triplanar_c1699351edff078e9f052737bbebcedb_Y * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.y + Triplanar_c1699351edff078e9f052737bbebcedb_Z * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.z;
            float _Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float = OverlayAmount;
            float4 _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4;
            Unity_Lerp_float4(Color_3ca898713668c983b29c8ff63f7d33c3, _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4, (_Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float.xxxx), _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4);
            float4 _Multiply_58be9a53fd903b8e990da8a3efb58f3f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_32acbc737c5148f6b02a278b3024364e_Out_0_Vector4, _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4, _Multiply_58be9a53fd903b8e990da8a3efb58f3f_Out_2_Vector4);
            float2 _Property_1c3ef19df37d435097bc1036819fbc2b_Out_0_Vector2 = _Tiling;
            float2 _Property_262e801cc00441f0b9d8e757d91c736a_Out_0_Vector2 = _Offset;
            float2 _TilingAndOffset_bcc14c74b53f466f86c1ffa9f287b64f_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_1c3ef19df37d435097bc1036819fbc2b_Out_0_Vector2, _Property_262e801cc00441f0b9d8e757d91c736a_Out_0_Vector2, _TilingAndOffset_bcc14c74b53f466f86c1ffa9f287b64f_Out_3_Vector2);
            float4 _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_bcc14c74b53f466f86c1ffa9f287b64f_Out_3_Vector2) );
            float _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_R_4_Float = _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4.r;
            float _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_G_5_Float = _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4.g;
            float _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_B_6_Float = _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4.b;
            float _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_A_7_Float = _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4.a;
            float4 _Multiply_d254ce4564e841a499d7e53f5ea86610_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_58be9a53fd903b8e990da8a3efb58f3f_Out_2_Vector4, _SampleTexture2D_705ebba9301f4b0583c9d8e92727ca33_RGBA_0_Vector4, _Multiply_d254ce4564e841a499d7e53f5ea86610_Out_2_Vector4);
            float _Property_6fc1cf12c45b463db43c22b144dc9fbe_Out_0_Float = _Opacity;
            float _Property_503974d382d54d43931e6fba219b7c91_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_89055baebdbe4acf8fc1418f372c07ac_Out_0_Vector2 = _TargetPos;
            float2 _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2;
            Unity_Remap_float2(_Property_89055baebdbe4acf8fc1418f372c07ac_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2);
            float2 _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4.xy), _Remap_64540db17df04245827e8498e65f05fc_Out_3_Vector2, _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2);
            float2 _TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_d2a7ed3f908b41a6b2acd4f69b38b418_Out_0_Vector4.xy), float2 (1, 1), _Add_07c1a02e47cd43308af3735af09d691f_Out_2_Vector2, _TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2);
            float2 _Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_afa5438b7d3a4cfe83f2f017450faa72_Out_3_Vector2, float2(2, 2), _Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2);
            float2 _Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_0060f8e49e4c486ebf564f2c6572ba79_Out_2_Vector2, float2(1, 1), _Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2);
            float _Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float = _Size;
            float _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float);
            float _Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float;
            Unity_Multiply_float_float(_Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float, _Divide_a633197ea7e343509ec07ffe243c78e2_Out_2_Float, _Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float);
            float2 _Vector2_a56798a6189b4c37ac30566894b1b8aa_Out_0_Vector2 = float2(_Multiply_753f2ee5040c4f19958ae984fee6c2e6_Out_2_Float, _Property_8fd9dae059b441d0b4a2fe45c5fa4cb1_Out_0_Float);
            float2 _Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_97acbd54b7554616b7ba23c13985bc57_Out_2_Vector2, _Vector2_a56798a6189b4c37ac30566894b1b8aa_Out_0_Vector2, _Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2);
            float _Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float;
            Unity_Length_float2(_Divide_7b943b5db90f49f5a77e2117aa72fa8e_Out_2_Vector2, _Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float);
            float _OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float;
            Unity_OneMinus_float(_Length_1385effdcf7f4032990adaaa3aadb6e6_Out_1_Float, _OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float);
            float _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float;
            Unity_Saturate_float(_OneMinus_38ca06ec89da494ba83aba30f1781c81_Out_1_Float, _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float);
            float _Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float;
            Unity_Smoothstep_float(0, _Property_503974d382d54d43931e6fba219b7c91_Out_0_Float, _Saturate_819ac1f8400d4c72811218639c816fd6_Out_1_Float, _Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float);
            float _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 50, _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float);
            float _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float, _GradientNoise_797e933bb6894d738c8c36fb9ab6073c_Out_2_Float, _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float);
            float _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float;
            Unity_Add_float(_Smoothstep_3643cd9df4074507b183f21243cd6ad7_Out_3_Float, _Multiply_b4ef98ba126e4a8b8ec9dd8ce8dec9e2_Out_2_Float, _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float);
            float _Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float;
            Unity_Multiply_float_float(_Property_6fc1cf12c45b463db43c22b144dc9fbe_Out_0_Float, _Add_4cff68a278284b35a081b09198b741e8_Out_2_Float, _Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float);
            float _Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float;
            Unity_Clamp_float(_Multiply_b762a6a8ca5343b29b89c640968f7964_Out_2_Float, 0, 1, _Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float);
            float _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float;
            Unity_OneMinus_float(_Clamp_9fa937877a934d5b87ef3b7c03f770bd_Out_3_Float, _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float);
            surface.BaseColor = (_Multiply_d254ce4564e841a499d7e53f5ea86610_Out_2_Vector4.xyz);
            surface.Alpha = _OneMinus_d8dd34b31023400a8a9af776efd359a3_Out_1_Float;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}