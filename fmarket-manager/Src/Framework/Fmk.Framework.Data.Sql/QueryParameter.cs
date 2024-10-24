using System;

namespace Fmk.Framework.Data.Sql
{
    public class QueryParameter
    {
        /// <summary>
        /// Initializes a new instance of <see cref="QueryParameter"/> (input parameter).
        /// </summary>
        /// <param name="index">The index.</param>
        /// <param name="name">The name.</param>
        /// <param name="value">The value.</param>
        /// <param name="entityDataType">Type of the entity data.</param>
        /// <param name="size">The size.</param>
        public QueryParameter(int index, string? name, object? value, Type entityDataType, int? size = null)
        {
            Index = index;
            Name = name;
            Value = value;
            EntityDataType = entityDataType;
            Size = size;
            IsOutput = false;
        }

        /// <summary>
        /// Initializes a new instance of <see cref="QueryParameter"/> (output parameter).
        /// </summary>
        /// <param name="index">The index.</param>
        /// <param name="name">The name.</param>
        /// <param name="entityDataType">Type of the entity data.</param>
        /// <param name="size">The size.</param>
        public QueryParameter(int index, string name, Type entityDataType, int? size = null)
        {
            Index = index;
            Name = name;
            Value = null;
            EntityDataType = entityDataType;
            Size = size;
            IsOutput = true;
        }

        public int Index { get; set; } = 0;
        public string? Name { get; set; }
        public object? Value { get; set; }
        public Type EntityDataType { get; set; }
        public int? Size { get; set; } = null;
        public bool IsOutput { get; set; } = false;
    }
}
