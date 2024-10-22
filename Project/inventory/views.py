from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import status

from .serializers import *

# Create your views here.
@api_view(['GET', 'POST'])
def inventory_index(request):
    if request.method == 'GET':
        return Response()
    elif request.method == 'POST':
        return Response()
