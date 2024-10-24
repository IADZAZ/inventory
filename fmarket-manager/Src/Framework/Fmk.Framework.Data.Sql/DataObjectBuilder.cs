using System;
using System.Data;
using System.Reflection;
using Fmk.Framework.Common.Extensions;
using Fmk.Framework.Common.Extensions.ObjectConversion;

namespace Fmk.Framework.Data.Sql
{
    public static class DataObjectBuilder
    {

        public static IList<T> PopulateProperties<T>(DataTable dataTable, IList<string>? propertiesToIgnore = null)
        {
            List<T> dataObjects = [];
            foreach (DataRow dataRow in dataTable.Rows)
            {
                dataObjects.Add(PopulateProperties<T>(dataRow, propertiesToIgnore));
            }
            return dataObjects;
        }

        public static T PopulateProperties<T>(DataRow dataRow, IList<string>? propertiesToIgnore = null)
        {
            var dataObject = Activator.CreateInstance(typeof(T));

            foreach (PropertyInfo propertyInfo in dataObject.GetType().GetProperties(BindingFlags.Public | BindingFlags.Instance))
            {
                // Set Property Type (if nullable, set type to non-nullable version).
                Type propertyInfoType = propertyInfo.PropertyType;
                if (propertyInfoType.IsGenericType && propertyInfoType.GetGenericTypeDefinition() == typeof(Nullable<>)) { propertyInfoType = propertyInfoType.GetGenericArguments().Single(); }

                // Skip ObjectList properties.
                if (propertyInfoType.GetGenericArguments().Length > 0) { continue; }

                // Skip property if it is in the Ignore list.
                if(propertiesToIgnore != null && propertiesToIgnore.Contains(propertyInfo.Name)) { continue; }
                SetPropertyValue(dataObject, propertyInfo, propertyInfoType, dataRow);
            }

            return (T)dataObject;
        }


        public static void PopulateListProperty<T, TR>(IList<TR> parentDataObjects, string parentProperyName, string parentIntPropertyValueMatch, string childIntRowValueMatch, DataTable childDataTable, IList<string>? propertiesToIgnore = null)
        {
            //// Property's Type must match type of child object (T).
            //if(typeof(TR).GetProperty(parentProperyName).GetType() != typeof(T))
            //{
            //    throw new ApplicationException($"the type of the parent DataObject's property {parentProperyName} ('{typeof(TR).GetProperty(parentProperyName).GetType()}') does not match the type of the child DataObject ({ typeof(T)}).");
            //}

            foreach (var parentDataObject in parentDataObjects)
            {
                int parentIntMatch = typeof(TR).GetProperty(parentIntPropertyValueMatch).GetValue(parentDataObject).ToSafeInt();

                List<T> childDataObjects = [];
                foreach (DataRow dataRow in childDataTable.Rows)
                {
                    if (dataRow[childIntRowValueMatch].ToSafeInt() == parentIntMatch)
                    {
                        childDataObjects.Add(PopulateProperties<T>(dataRow, propertiesToIgnore));
                    }
                }

                if (childDataObjects.Count > 0)
                {
                    typeof(TR).GetProperty(parentProperyName).SetValueWithPotentiallyPrivateSetter(parentDataObject, childDataObjects);
                }
            }
        }

        public static void SetPropertyValue<T>(T dataObject, PropertyInfo propertyInfo, Type propertyInfoType, DataRow row)
        {
            propertyInfo.SetValueWithPotentiallyPrivateSetter(dataObject, Convert.ChangeType(row[propertyInfo.Name], propertyInfoType));

            //switch (propertyInfoType.Name)
            //{
            //    case "Int32":
            //        propertyInfo.SetValue(dataObject, row[propertyInfo.Name].ToSafeInt(), null);
            //        break;
            //    case "Int64":
            //        propertyInfo.SetValue(dataObject, row[propertyInfo.Name].ToSafeLong(), null);
            //        break;
            //    case "Bool":
            //        propertyInfo.SetValue(dataObject, row[propertyInfo.Name].ToSafeBool(), null);
            //        break;
            //    case "Decimal":
            //        propertyInfo.SetValue(dataObject, row[propertyInfo.Name].ToSafeDecimal(), null);
            //        break;
            //    case "Double":
            //        propertyInfo.SetValue(dataObject, row[propertyInfo.Name].ToSafeDouble(), null);
            //        break;
            //    case "DateTime":
            //        propertyInfo.SetValue(dataObject, row[propertyInfo.Name].ToSafeDate(), null);
            //        break;
            //    case "DateTimeOffset":
            //        propertyInfo.SetValue(dataObject, row[propertyInfo.Name].ToSafeDateTimeOffset(), null);
            //        break;
            //    case "Guid":
            //        propertyInfo.SetValue(dataObject, row[propertyInfo.Name].ToSafeGuid(), null);
            //        break;
            //    case "String":
            //    default:
            //        propertyInfo.SetValue(dataObject, row[propertyInfo.Name].ToSafeString(), null);
            //        break;
            //}
        }
    }
}
