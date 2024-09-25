#!/bin/bash

if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
  exit 0
fi

QUERY_RESULT=$(psql -U postgres -d periodic_table -t -c "
  SELECT elements.atomic_number, elements.name, elements.symbol, types.type, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius
  FROM elements
  JOIN properties ON elements.atomic_number = properties.atomic_number
  JOIN types ON properties.type_id = types.type_id
  WHERE elements.atomic_number::text = '$1'
  OR elements.symbol ILIKE '$1'
  OR elements.name ILIKE '$1';
")


# Check if the query returned any results
if [[ -z $QUERY_RESULT ]]; then
  echo "I could not find that element in the database."
else
  # Use read to parse the result and trim leading/trailing spaces
  echo "$QUERY_RESULT" | while IFS='|' read -r atomic_number name symbol type atomic_mass melting_point_celsius boiling_point_celsius; do
    # Use xargs to trim spaces
    atomic_number=$(echo "$atomic_number" | xargs)
    name=$(echo "$name" | xargs)
    symbol=$(echo "$symbol" | xargs)
    type=$(echo "$type" | xargs)
    atomic_mass=$(echo "$atomic_mass" | xargs)
    melting_point_celsius=$(echo "$melting_point_celsius" | xargs)
    boiling_point_celsius=$(echo "$boiling_point_celsius" | xargs)

    echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."
  done
fi
