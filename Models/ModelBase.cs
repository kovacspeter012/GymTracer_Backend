using GymTracer.Extensions;

namespace GymTracer.models
{
    public abstract class ModelBase<T> where T : ModelBase<T>, new()
    {
        public static T Deserialize(string json)
        {
            return json.Deserialize<T>();
        }
    }
}
